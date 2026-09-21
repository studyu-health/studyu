/// This is an answer type [Answer\<FutureBlobFile\>] used by multimodal questions to store the [localFilePath] and
/// the [futureBlobId] of a file. The local file will will be uploaded to the blob storage during the completion
/// of the questionnaire. This is a temporary answer type, which is not stored in the database. It will be replaced
/// by [Answer\<String\>], in which the String is the [futureBlobId].
class FutureBlobFile(final String localFilePath, final String futureBlobId);
