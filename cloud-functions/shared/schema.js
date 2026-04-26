const schema = require('../cloud-db/schema.json');

function getCollectionSchema(collectionName) {
  const collections = schema.collections || [];
  for (let i = 0; i < collections.length; i++) {
    if (collections[i].name === collectionName) {
      return collections[i];
    }
  }
  throw new Error(`Schema not found for collection: ${collectionName}`);
}

module.exports = {
  getCollectionSchema
};
