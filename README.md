# react-native-icloud
wrapping nsfilemanager for icloud usage

## Installation:

Put `RCTICloudDocuments.m` in your XCode Project

## Usage:
```javascript
var Documents = React.NativeModules.ICloudDocuments;

// get iCloud token
Documents.getICloudToken((err, token)=>{});

// get iCloud or local doc root
Documents.iCloudDocumentPath((err, path)=>{});
Documents.documentPath((err, path)=>{});

// copy and overwrite file to or from iCloud
Documents.replaceFileToICloud(localPath, (err,resultURL)=>{});
Documents.replaceFileFromICloud(iCloudPath, (err,resultURL)=>{});

// copy file to or from iCloud
Documents.copyFileToICloud(localPath, (err,resultURL)=>{});
Documents.copyFileFromICloud(iCloudPath, (err,resultURL)=>{});

// move file to or from iCloud
Documents.moveFileToICloud(localPath, (err,resultURL)=>{});
Documents.moveFileFromICloud(iCloudPath, (err,resultURL)=>{});

// get file attributes with path
Documents.attributesOfItemAtPath(path,(err,attrs)=>{});

// contents at item or directory
Documents.contentsAtPath(manifest,(err,contents)=>{}); // utf8 encoded
Documents.contentsOfDirectoryAtPath(path, (err, files)=>{});

// remove file with path
Documents.removeFileAtPath(pathToRemove,(err, isSuccess)=>{});
```
