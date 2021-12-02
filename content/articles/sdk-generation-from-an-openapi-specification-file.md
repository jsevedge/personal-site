---
title: "SDK Generation from an OpenAPI Specification File"
author: "James Sevedge"
meta_desc: ""
date: 2021-12-01
show_reading_time: true
tags: []
---

Recently I spent a fair amount of time exploring the SDK generation space for a prototype our team was building at my current employer.  Along the way I captured a few thoughts which I will break down here about what SDK generation is and some ways to go about it.  Let's get some context first by starting with a problem statement.

**Problem Statement**

Let's say we are responsible for the usability of a SaaS service at XYZ company which has a RESTful API, and since this service is taking off we have begun to get requests for a better developer user experience (UX).  Looking to peers in the industry with similar services a common composability pattern emerges, specifically something such as the following.

{{<mermaid>}}
graph TD;
    api_service["Native API Service (Imperative)"];
    api_service_declarative["Native API Service (Declarative)"];
    sdk_python["SDK Binding (Python)"];
    sdk_go["SDK Binding (Go)"];
    sdk_js["SDK Binding (Javascript)"];
    cli["CLI (written in Go)"];
    terraform["Terraform (written in Go)"];
    ansible["Ansible (written in Python)"];
    api_service_declarative --> api_service;
    sdk_python --> api_service;
    sdk_python --> api_service_declarative;
    sdk_go--> api_service;
    sdk_go --> api_service_declarative;
    sdk_js--> api_service;
    sdk_js --> api_service_declarative;
    cli --> sdk_go;
    terraform --> sdk_go;
    ansible --> sdk_python;
{{</mermaid>}}

This pattern is used by most of the major SaaS providers, to varying degrees of maturity.  It allows the developer UX to naturally evolve out and away from the core competencies (native API service + a declarative API service for companies that understand the customer value proposition of a declarative model and choose to provide that experience natively) to whatever integration point makes the most sense for the consumer of the service.

The technical issue with this pattern of course is how to propagate out changes that occur in the core competencies to all the upstream bindings and external integration points automagically.  The assumption is in most cases it would not be feasible both from a manpower and delivery management perspective to try and do this without tooling and automation.  So let's take some time to think about SDK generation since that is the set of bindings immediately upstream of the core APIs.

*Future Post*: Once you have the SDK bindings problem solved you can use those in Terraform/Ansible and tackle the problem of if/how to automate updates to those providers/modules.  One step at a time though!

**Existing SDK Generation Tooling**

Most SDK generation tooling research starts by googling "SDK Generation Tool" and ends with finding [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator), which is listed on [openapi.tools](https://openapi.tools/#sdk).  OpenAPI Generator is probably the the most popular open-source OpenAPI based SDK generator available, it was a fork of the original [Swagger CodeGen](https://swagger.io/tools/swagger-codegen/).

If you use one of these common generators they take an [OpenAPI](https://www.openapis.org) specification file which describes the service API endpoints in as much detail as you like and uses common properties such as HTTP methods, HTTP uri and so on to generate bindings for 1+ programming languages.  If the default output works for you without additional customization for company branding, etc. you can stop here.  If you either don't want to learn how to customize those bindings (see [OpenAPI Generator templating](https://openapi-generator.tech/docs/templating/)) or you want to understand how SDK generation works in more detail let's dive into the details.

**Building an SDK Generator**

In this section let's walk through the steps I took to go from an OpenAPI specification document to a working set of python client bindings.

1) Given a simple OpenAPI specification document

  ```yaml
  openapi: 3.0.0
  info:
    title: Example API Specification
    description: Example Description
    version: 1.0.0
  servers:
  - url: https://192.0.2.10
    description: Mock Server
  paths:
    /applications:
      get:
        summary: List all applications
        description: List all applications
        operationId: getApplications
        tags:
          - Application
        responses:
          '200':
            description: OK
            content:
              application/json:
                schema:
                  type: array
                  items:
                    type: object
                    properties:
                      name:
                        type: string
      put:
        summary: Add a new application
        description: Add a new application
        operationId: createApplication
        tags:
          - Application
        requestBody:
          description: Example Description
          required: true
          content:
            application/json:
              schema:
                type: object
                properties:
                  name:
                    type: string
        responses:
            '200':
              description: OK
  ```
  
2) Parse and normalize into a model an SDK generator (and cooresponding templates) can understand

  ```yaml
  packageMetadata:
      name: Example API Specification
      version: 1.0.0
      description: Example Description
  globalConfiguration:
      host: https://192.0.2.10
  namespaces:
      - namespace: Application
        operations:
          - name: getApplications
            description: List all applications
            transportSettings:
              method: 'GET'
              url: /applications
          - name: createApplication
            description: Add a new application
            transportSettings:
              method: 'PUT'
              url: /applications
              requestBodyRequired: true
  ```

3) Render that generator model against a language-specific template set (Mustache, etc.), in this case Python

  ```mustache
  """{{namespace}} Client"""

  from mysdk.base_clients import BaseFeatureClient

  class {{namespace}}Client(BaseFeatureClient):
      """{{namespace}} Client """

      def __init__(self, client, **kwargs):
          """Initialization """

          super({{namespace}}Client, self).__init__(
              client,
              logger_name=__name__,
              uri='/'
          )

      {{#operations}}
      def {{name}}(self, **kwargs):
          """{{description}}"""

          {{#transportSettings.requestBodyRequired}}
          return self._make_request(
              method='{{transportSettings.method}}',
              uri='{{transportSettings.url}}',
              body=kwargs.pop('config', None)
          )
          {{/transportSettings.requestBodyRequired}}
          {{^transportSettings.requestBodyRequired}}
          return self._make_request(
              method='{{transportSettings.method}}',
              uri='{{transportSettings.url}}'
          )
          {{/transportSettings.requestBodyRequired}}

      {{/operations}}
  ```

4) The render operation outputs the following functional SDK with a service client per namespace (group/tag/etc)

  ```python
  # application.py
  """Application Client"""

  from mysdk.base_clients import BaseFeatureClient

  class ApplicationClient(BaseFeatureClient):
      """Application Client """

      def __init__(self, client, **kwargs):
          """Initialization """

          super(ApplicationClient, self).__init__(
              client,
              logger_name=__name__,
              uri='/'
          )

      def get_applications(self, **kwargs):
          """List all applications"""

          return self._make_request(
              method='GET',
              uri='/applications'
          )

      def create_application(self, **kwargs):
          """Add a new application"""

          return self._make_request(
              method='PUT',
              uri='/applications',
              body=kwargs.pop('config', None)
          )
  ```

5) Ship it!

Seems pretty easy right?  Let's look at some of the mappings:

- `path.method.tags[0]` -> Class name (operation/method grouping)
- `path` -> Method transport URI
- `path.method` -> Method transport verb
- `path.method.operationId` -> Method signature (name)
- `path.method.description` -> Method description

Of course this is the bare minimum necessary to generate a binding that could be useful, some other considerations that immediately present themselves are:

- What is necessary to define request/response interfaces for strongly typed languages?
- Do management clients (auth, low-level transport) need to be auto-generated?  If so what additional properties in the authentication endpoints (Basic, OAuth) OpenAPI specification files will need to be specified?
- How should APIs with support for async operations be handled?
- How would additional information such as namespace level usage examples be codified?
- How much logic should be considered MVP in the core package, such as authentication token refresh, transport level retries and so on?

Most of this initial set of problems are solvable simply by determining the minimal set of properties necessary for each endpoint to generate the appropriate generation model, enforcing that set of properties with a linter and then creating the appropriate templates/tooling to make use of that model.

**Industry SDK Generation Examples**

Here are some examples of popular industry API providers and the approach they took to SDK generation.

- Microsoft Azure:
    - Specification Location: https://github.com/Azure/azure-rest-api-specs
    - SDK Generator: https://github.com/Azure/autorest, https://github.com/Azure/autorest/blob/master/docs/trampoline.md, https://github.com/Azure/azure-rest-api-specs/tree/master/specification/compute/resource-manager
- AWS:
    - Specification Location: https://github.com/boto/boto3/tree/master/boto3/data, https://github.com/aws/aws-sdk-js/blob/master/apis, 
    - SDK Generator: It appears they manually define the "apis" and SDK methods using JSON and use that during generation
- GCP:
    - Specification Location: https://github.com/googleapis/googleapis
    - SDK Generator: https://google.aip.dev/client-libraries/4210, https://github.com/googleapis/gapic-generator, https://github.com/googleapis/gapic-generator-python
- Kubernetes
    - Specification Location: https://github.com/kubernetes/kubernetes/tree/master/api/openapi-spec, https://github.com/kubernetes-client
    - SDK Generator: It looks like they might be using openapi-generator with their own customization. Here are the scripts they are using to invoke the generator https://github.com/kubernetes-client/gen


**Final Thoughts**

As previously stated the deeper you go down the rabbit hole the more you have to consider, but getting a working prototype of a custom SDK generator is not that difficult.  Most of the industry examples provided above ended up going down that route to provide the best developer UX possible for their customers since they have the scale and resourcing necessary.