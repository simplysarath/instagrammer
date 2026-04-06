const sdk = require('node-appwrite');
const fetch = require('node-fetch');
const sharp = require('sharp');
const FormData = require('form-data');

module.exports = async ({ req, res, log, error }) => {
  let body = {};
  try {
    body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
  } catch (e) {
    return res.json({ error: 'Invalid request body' }, 400);
  }

  const fileId = body.file_id;
  if (!fileId) {
    return res.json({ error: 'file_id is required' }, 400);
  }

  const endpoint = process.env.APPWRITE_ENDPOINT ?? process.env.APPWRITE_FUNCTION_API_ENDPOINT;
  const projectId = process.env.APPWRITE_PROJECT_ID ?? process.env.APPWRITE_FUNCTION_PROJECT_ID;
  const apiKey = process.env.APPWRITE_API_KEY;

  log(`endpoint=${endpoint} projectId=${projectId} hasApiKey=${!!apiKey} hasRemoveBgKey=${!!process.env.REMOVEBG_API_KEY}`);

  const client = new sdk.Client()
    .setEndpoint(endpoint)
    .setProject(projectId)
    .setKey(apiKey);

  const storage = new sdk.Storage(client);

  try {
    // Download image from Appwrite Storage
    const fileBytes = await storage.getFileDownload(
      process.env.APPWRITE_BUCKET_ID || 'product-images',
      fileId
    );

    let imageBuffer = Buffer.from(fileBytes);

    // Check file size — Remove.bg free tier has 10MB limit
    // Compress to max 4MP (2048x2048) if needed
    const MAX_BYTES = 10 * 1024 * 1024;
    if (imageBuffer.length > MAX_BYTES) {
      log(`Image too large (${imageBuffer.length} bytes), compressing to max 4MP`);
      imageBuffer = await sharp(imageBuffer)
        .resize(2048, 2048, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 85 })
        .toBuffer();
      log(`Compressed to ${imageBuffer.length} bytes`);
    }

    // Call Remove.bg API
    const formData = new FormData();
    formData.append('image_file', imageBuffer, {
      filename: 'image.jpg',
      contentType: 'image/jpeg',
    });
    formData.append('size', 'auto');

    const removeBgResponse = await fetch('https://api.remove.bg/v1.0/removebg', {
      method: 'POST',
      headers: {
        'X-Api-Key': process.env.REMOVEBG_API_KEY,
        ...formData.getHeaders(),
      },
      body: formData,
    });

    if (!removeBgResponse.ok) {
      const errText = await removeBgResponse.text();
      error(`Remove.bg error: ${removeBgResponse.status} ${errText}`);
      return res.json({ error: 'bg_removal_failed' });
    }

    const resultBuffer = Buffer.from(await removeBgResponse.arrayBuffer());

    // Upload result PNG back to product-images bucket
    const bucketId = process.env.APPWRITE_BUCKET_ID || 'product-images';
    const newFileId = sdk.ID.unique();

    // node-appwrite requires InputFile for uploads
    const { InputFile } = sdk;
    const newFile = await storage.createFile(
      bucketId,
      newFileId,
      InputFile.fromBuffer(resultBuffer, `${newFileId}-nobg.png`)
    );

    log(`Background removed: original=${fileId}, new=${newFile.$id}`);
    return res.json({ new_file_id: newFile.$id });

  } catch (e) {
    error(`remove-background failed: ${e.message}`);
    return res.json({ error: 'bg_removal_failed' });
  }
};
