---
title: "An Excercise In Refactoring"
author: "James Sevedge"
meta_desc: ""
date: 2021-11-09
---

In my humble experience any discussion about refactoring should start with [Refactoring](https://martinfowler.com/books/refactoring.html) (Martin Fowler/Kent Beck) and [Clean Code](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) (Robert Martin).  Having at least a rudimentary understanding of the design patterns presented in [Gang of Four](https://www.amazon.com/gp/product/0201633612/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0201633612&linkCode=as2&tag=martinfowlerc-20) is helpful too.

It can be daunting to know where exactly to begin with those resources or understand why it matters so let's dive into the following concrete example to provide some clarity on what refactoring a module *may* look like.

## Refactoring Excercise

Let's start with some code that could use a little (or a lot of!) refactoring…

```javascript
const axios = require('axios');

function uploadFiles() {
    const loginResponse = await axios({
        url: 'https://the-cloud/api/v1/login',
        'GET',
        auth: {
            username: 'a_username',
            password: 'a_password'
        },
        validateStatus: false
    });
    if (loginResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${loginResponse.status} ${loginResponse.data}`)
    }
    const authToken = loginResponse.data.token;
    const encodedCertificateProduction = Buffer.from(data).toString('certificate for production environment');
    const encodedKeyProduction = Buffer.from(data).toString('key for production environment');
    const productionFile = {
        description: 'Production certificate/key',
        name: 'production_file',
        certificate: encodedCertificateProduction,
        key: encodedKeyProduction,
        metadata: {
            env: 'production'
        }
    };
    const productionFileResponse = await axios({
        url: 'https://the-cloud/api/v1/storage/my-bucket',
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: productionFile,
        validateStatus: false
    });
    if (productionFileResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${productionFileResponse.status} ${productionFileResponse.data}`)
    }
    const encodedCertificateStaging = Buffer.from(data).toString('certificate for staging environment');
    const encodedKeyStaging = Buffer.from(data).toString('key for staging environment');
    const stagingFile = {
        description: 'Staging certificate/key',
        name: 'staging_file',
        certificate: encodedCertificateStaging,
        key: encodedKeyStaging,
        metadata: {
            env: 'staging'
        }
    };
    const stagingFileResponse = await axios({
        url: 'https://the-cloud/api/v1/storage/my-bucket',
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: stagingFile,
        validateStatus: false
    });
    if (stagingFileResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${stagingFileResponse.status} ${stagingFileResponse.data}`)
    }
}

await uploadFiles();
```

How hard was it tell the purpose of the code and did the code "smell" at all to you?  If so, how?

### Readability

The first thing you notice may be how hard it is to understand what the code is doing, so let's add some comments (for now, more on that later) to help the developers reading this code.

Actions to take: 1) Add some comments to `uploadFiles`

```javascript
const axios = require('axios');

function uploadFiles() {
    // login to "the cloud" and get a token
    const loginResponse = await axios({
        url: 'https://the-cloud/api/v1/login',
        'GET',
        auth: {
            username: 'a_username',
            password: 'a_password'
        },
        validateStatus: false
    });
    if (loginResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${loginResponse.status} ${loginResponse.data}`)
    }
    const authToken = loginResponse.data.token;
    // encode production certificate/key
    const encodedCertificateProduction = Buffer.from(data).toString('certificate for production environment');
    const encodedKeyProduction = Buffer.from(data).toString('key for production environment');
    // create production certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    const productionFile = {
        description: 'Production certificate/key',
        name: 'production_file',
        certificate: encodedCertificateProduction,
        key: encodedKeyProduction,
        metadata: {
            env: 'production'
        }
    };
    // upload production certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    const productionFileResponse = await axios({
        url: 'https://the-cloud/api/v1/storage/my-bucket',
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: productionFile,
        validateStatus: false
    });
    if (productionFileResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${productionFileResponse.status} ${productionFileResponse.data}`)
    }
    // create staging certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    const encodedCertificateStaging = Buffer.from(data).toString('certificate for staging environment');
    const encodedKeyStaging = Buffer.from(data).toString('key for staging environment');
    const stagingFile = {
        description: 'Staging certificate/key',
        name: 'staging_file',
        certificate: encodedCertificateStaging,
        key: encodedKeyStaging,
        metadata: {
            env: 'staging'
        }
    };
    // upload staging certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    const stagingFileResponse = await axios({
        url: 'https://the-cloud/api/v1/storage/my-bucket',
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: stagingFile,
        validateStatus: false
    });
    if (stagingFileResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${stagingFileResponse.status} ${stagingFileResponse.data}`)
    }
}

await uploadFiles();
```

### Duplication

Ok, that is a little better… at least it is easier to understand what is happening.  But the function is still large and there are blocks of code that are almost exactly the same so let's extract those into some helper methods.

Actions to take: 1) Create `_generateFile` function and use it in `uploadFiles` for both environments 2) Create `_uploadFile` function and use it in `uploadFiles` for both environments 

```javascript
const axios = require('axios');

function uploadFiles() {
    // login to "the cloud" and get a token
    const loginResponse = await axios({
        url: 'https://the-cloud/api/v1/login',
        'GET',
        auth: {
            username: 'a_username',
            password: 'a_password'
        },
        validateStatus: false
    });
    if (loginResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${loginResponse.status} ${loginResponse.data}`)
    }
    const authToken = loginResponse.data.token;
    // create production certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    const productionFile = _generateFile('production', 'certificate for production environment', 'key for production environment');
    // upload production certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    await _uploadFile(authToken, productionFile);
    // create staging certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    const stagingFile = _generateFile('staging', 'certificate for staging environment', 'key for staging environment');
    // upload staging certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    await _uploadFile(authToken, stagingFile);
}

function _generateFile(environment, certificate, key) {
    return = {
        description: `${environment} certificate/key`,
        name: `${environment}_file`,
        certificate: Buffer.from(data).toString(certificate),
        key: Buffer.from(data).toString(key),
        metadata: {
            env: environment
        }
    };
}

async function _uploadFile(authToken, file) {
    const response = await axios({
        url: 'https://the-cloud/api/v1/storage/my-bucket',
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: file,
        validateStatus: false
    });
    if (response.status !== 200) {
        throw new Error(`HTTP request failed: ${response.status} ${response.data}`)
    }
    return response.data;
}

await uploadFiles();
```

### Extract functionality

Now `uploadFiles` is starting to look pretty good, but just because code is not duplicated does not mean it shouldn't be extracted.  If there is a block of code that makes sense to extract out, do it.

Actions To Take: 1) Extract out `login` functionality and use it in `uploadFiles` 2) Extract out `_generateAndUploadFile` functionality and use it in `uploadFiles`

```javascript
const axios = require('axios');

function uploadFiles() {
    // login to "the cloud" and get a token
    const authToken = await _login('a_username', 'a_password');
    // create production certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    // upload production certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    await _generateAndUploadFile(authToken, 'production', 'certificate for production environment', 'key for production environment')
    // create staging certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    // upload staging certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    await _generateAndUploadFile(authToken, 'staging', 'certificate for staging environment', 'key for staging environment')
}

async function _generateAndUploadFile(authToken, environment, certificate, key) {
    await _uploadFile(authToken, _generateFile(environment, certificate, key));
}

function _generateFile(environment, certificate, key) {
    return = {
        description: `${environment} certificate/key`,
        name: `${environment}_file`,
        certificate: Buffer.from(data).toString(certificate),
        key: Buffer.from(data).toString(key),
        metadata: {
            env: environment
        }
    };
}

async function _login(username, password) {
    const loginResponse = await axios({
        url: 'https://the-cloud/api/v1/login',
        'GET',
        auth: {
            username: username,
            password: password
        },
        validateStatus: false
    });
    if (loginResponse.status !== 200) {
        throw new Error(`HTTP request failed: ${loginResponse.status} ${loginResponse.data}`)
    }
    return response.data.token;
}

async function _uploadFile(authToken, file) {
    const response = await axios({
        url: 'https://the-cloud/api/v1/storage/my-bucket',
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: file,
        validateStatus: false
    });
    if (response.status !== 200) {
        throw new Error(`HTTP request failed: ${response.status} ${response.data}`)
    }
    return response.data;
}

await uploadFiles();
```

### Magic strings

Avoid [magic strings](https://en.wikipedia.org/wiki/Magic_string), there are a number of them still.  In this refactoring example we will not delve into how some of these items (username, password, certificate/key content, etc.) should probably be provided as input or loaded from the environment, but let's at least not sprinkle them throughout the code.

Actions to take: 1) Move magic strings to the top of the module and update references

```javascript
const axios = require('axios');

const CLOUD_SERVICE_API = 'https://the-cloud/api/v1';
const USERNAME = 'a_username';
const PASSWORD = 'a_password';
const TLS_CONTENT = {
    'production': {
        certificate: 'certificate for production environment',
        key: 'key for production environment'
    },
    'staging': {
        certificate: 'certificate for staging environment',
        key: 'key for staging environment'
    }
}
const HTTP_RESPONSE_CODES = {
    SUCCESS: 200
}

function uploadFiles() {
    // login to "the cloud" and get a token
    const authToken = await _login(USERNAME, PASSWORD);
    // create production certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    // upload production certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    await _generateAndUploadFile(authToken, 'production', TLS_CONTENT['production'].certificate, TLS_CONTENT['production'].key)
    // create staging certificate/key file contents (axios will JSON stringify the JavaScript object for us)
    // upload staging certificate/key file contents (uses name in HTTP body to create a file under "my-bucket")
    await _generateAndUploadFile(authToken, 'staging', TLS_CONTENT['staging'].certificate, TLS_CONTENT['staging'].key)
}

async function _generateAndUploadFile(authToken, environment, certificate, key) {
    await _uploadFile(authToken, _generateFile(environment, certificate, key));
}

function _generateFile(environment, certificate, key) {
    return = {
        description: `${environment} certificate/key`,
        name: `${environment}_file`,
        certificate: Buffer.from(data).toString(certificate),
        key: Buffer.from(data).toString(key),
        metadata: {
            env: environment
        }
    };
}

async function _login(username, password) {
    const loginResponse = await axios({
        url: `${CLOUD_SERVICE_API}/login`,
        'GET',
        auth: {
            username: username,
            password: password
        },
        validateStatus: false
    });
    if (loginResponse.status !== HTTP_RESPONSE_CODES.SUCCESS) {
        throw new Error(`HTTP request failed: ${loginResponse.status} ${loginResponse.data}`)
    }
    return response.data.token;
}

async function _uploadFile(authToken, file) {
    const response = await axios({
        url: `${CLOUD_SERVICE_API}/storage/my-bucket`,
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: file,
        validateStatus: false
    });
    if (response.status !== HTTP_RESPONSE_CODES.SUCCESS) {
        throw new Error(`HTTP request failed: ${response.status} ${response.data}`)
    }
    return response.data;
}

await uploadFiles();
```

### Remove unnecessary comments

Well now those comments are starting to look a little silly, the methods are named well enough to allow readers to understand what is going on without them.  Let's just remove the comments.

Actions to take: 1) Remove unnecessary comments

```javascript
const axios = require('axios');

const CLOUD_SERVICE_API = 'https://the-cloud/api/v1';
const USERNAME = 'a_username';
const PASSWORD = 'a_password';
const TLS_CONTENT = {
    'production': {
        certificate: 'certificate for production environment',
        key: 'key for production environment'
    },
    'staging': {
        certificate: 'certificate for staging environment',
        key: 'key for staging environment'
    }
}
const HTTP_RESPONSE_CODES = {
    SUCCESS: 200
}

function uploadFiles() {
    const authToken = await _login(USERNAME, PASSWORD);
    await _generateAndUploadFile(authToken, 'production', TLS_CONTENT['production'].certificate, TLS_CONTENT['production'].key)
    await _generateAndUploadFile(authToken, 'staging', TLS_CONTENT['staging'].certificate, TLS_CONTENT['staging'].key)
}

async function _generateAndUploadFile(authToken, environment, certificate, key) {
    await _uploadFile(authToken, _generateFile(environment, certificate, key));
}

function _generateFile(environment, certificate, key) {
    return = {
        description: `${environment} certificate/key`,
        name: `${environment}_file`,
        certificate: Buffer.from(data).toString(certificate),
        key: Buffer.from(data).toString(key),
        metadata: {
            env: environment
        }
    };
}

async function _login(username, password) {
    const loginResponse = await axios({
        url: `${CLOUD_SERVICE_API}/login`,
        'GET',
        auth: {
            username: username,
            password: password
        },
        validateStatus: false
    });
    if (loginResponse.status !== HTTP_RESPONSE_CODES.SUCCESS) {
        throw new Error(`HTTP request failed: ${loginResponse.status} ${loginResponse.data}`)
    }
    return response.data.token;
}

async function _uploadFile(authToken, file) {
    const response = await axios({
        url: `${CLOUD_SERVICE_API}/storage/my-bucket`,
        'POST',
        headers: {
            Authorization: `Bearer ${authToken}`
        },
        data: file,
        validateStatus: false
    });
    if (response.status !== HTTP_RESPONSE_CODES.SUCCESS) {
        throw new Error(`HTTP request failed: ${response.status} ${response.data}`)
    }
    return response.data;
}

await uploadFiles();
```

## Futher optimizations

There is more that can be done to this code of course, such as 1) moving the low level cloud service API interaction to a `CloudApiClient` class to encapsulate that functionality (and allow support via polymorphism for another cloud) 2) creating a `FilesClient` class to encapsulate cloud service file operation behavior 3) wrapping the top level certificate and key upload business logic into a class which handles loading the files from the environment and calling the other classes 4) and so on…

{{<mermaid>}}
classDiagram
    class CloudApiClient{
        +login()
        +makeRequest()
    }
    class FilesClient{
        +init()
        +uploadFile()
    }
    class CertificateAndKeyUploader{
        +uploadFiles()
    }
    CertificateAndKeyUploader ..> FilesClient
    FilesClient ..> CloudApiClient
{{</mermaid>}}

but this at least covers the broad strokes of what refactoring a module might look like.

## Additional Resources

I find that once you have a foundational understanding of code refactoring, you simply need to excercise that knowledge over time to get better… but to get a refresher on specific principles you can go to the wonderful site [refactoring.com](https://refactoring.com) and check out the [catalog](https://refactoring.com/catalog/).  I also highly recommend, when the time is right, to find and spend the time to watch the "Uncle Bob" Clean Code [series](https://www.youtube.com/watch?v=7EmboKQH8lM) where he goes into detail about the topics covered in his book.