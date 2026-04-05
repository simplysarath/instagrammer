const sdk = require('node-appwrite');
const fetch = require('node-fetch');

module.exports = async ({ req, res, log, error }) => {
  // Parse request body
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

  // Initialize Appwrite client
  const client = new sdk.Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY);

  const storage = new sdk.Storage(client);

  try {
    // Download image from Appwrite Storage
    const fileBytes = await storage.getFileDownload(
      process.env.APPWRITE_BUCKET_ID || 'product-images',
      fileId
    );

    // Convert to base64 for Ximilar API
    const base64Image = Buffer.from(fileBytes).toString('base64');

    // Call Ximilar Fashion Tagging API
    const ximilarResponse = await fetch(
      'https://api.ximilar.com/tagging/fashion/v2/tag',
      {
        method: 'POST',
        headers: {
          'Authorization': `Token ${process.env.XIMILAR_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          records: [{ '_base64': base64Image }],
        }),
      }
    );

    if (!ximilarResponse.ok) {
      error(`Ximilar API error: ${ximilarResponse.status}`);
      return res.json({ garment_type: '', fabric: null, color: null, occasion: null, age_group: null });
    }

    const ximilarData = await ximilarResponse.json();
    const records = ximilarData.records || [];
    const record = records[0] || {};

    // Map Ximilar response to ProductTags schema
    // category.name → garment_type
    // fabric.name → fabric
    // dominant_color.name → color
    // occasions[0].name → occasion
    // age_group.name → age_group
    const extractName = (field) => {
      if (!field) return null;
      if (Array.isArray(field)) return field.length > 0 ? (field[0].name || null) : null;
      return field.name || null;
    };

    const tags = {
      garment_type: extractName(record.category) || '',
      fabric: extractName(record.fabric),
      color: extractName(record.dominant_color),
      occasion: extractName(record.occasions),
      age_group: extractName(record.age_group),
    };

    log(`Tagged file ${fileId}: garment_type=${tags.garment_type}`);
    return res.json(tags);

  } catch (e) {
    error(`tag-product failed: ${e.message}`);
    // Return empty tags on failure — Flutter will show editable empty chips
    return res.json({ garment_type: '', fabric: null, color: null, occasion: null, age_group: null });
  }
};
