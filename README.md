# react-native-icloud
wrapping nsfilemanager for icloud usage

```javascript
var Documents = React.NativeModules.ICloudDocuments;
Documents.attributesOfItemAtPath(path,(err,attrs)=>{});
Documents.contentsAtPath(manifest,(err,contents)=>{});
Documents.contentsOfDirectoryAtPath(path, (err, files)=>{});
Documents.copyFileToICloud(manifest,(err,attrs)=>{});
Documents.documentPath((path)=>{});
Documents.iCloudDocumentPath((path)=>{});
Documents.getICloudDocumentURLByLocalPath(localPath,(iCloudPath)=>{});
Documents.getICloudToken((token)=>{});
Documents.moveFileToICloud(localPath,(err, result)=>{});
Documents.removeICloudFile(iCloudPath,(err, isSuccess)=>{});
```
