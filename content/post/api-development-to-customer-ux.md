---
title: "API Development (Beyond the Specification Document)"
author: "James Sevedge"
meta_desc: ""
date: 2020-05-20
---

Creating an API that is well though out, scales and adopts industry standards can be quite difficult.  Creating that API while keeping the end consumer User Experience (UX) at the forefront adds even more cognitive load, however the payoff is worth it in the long run to stay disciplined and consider it from the start.  Let's talk about what that flow might look like at a high level including some example tooling and processes.

First let's assume you have a good API design in place which has been peer-reviewed and articulated in a human and machine readable format, for example if creating a REST API you may articulate this using [OpenAPI](https://openapis.org/), [API Blueprint](https://apiblueprint.org/) or some other similar mechanism.  In this example let's assume you have been using OpenAPI.

If the OpenAPI specification document describes your API, let's strive to keep it that way.  That is the *source of truth*.  Given that assumption all consumer UX should be derived from that document.

Ok great, but my API is already implemented so what more is needed here?  And who is this mysterious "consumer" that demands more than simply a running instance of the API?

The most common consumer of API's is other developers trying to make use of your technology platform to accomplish a specific set of tasks which fit into a larger goal.  To enable adoption of the API you must consider a variety of artifacts, including API documentation, hand-crafted examples to describe certain 80/20 usage patterns, multi-language binding SDK bindings and more.

Before picking any specific tool you need to do research to ensure any tooling selected makes good design sense (more on that later).  One such resource is [https://openapi.tools](https://openapi.tools).  That being said let's take a look at the below UML flow diagram and then map that to a specific tool.

{{<mermaid>}}
graph TD;
    api_spec_a["API Specification (Offering A: /service-1)"] --> sdk_tooling;
    api_spec_b["API Specification (Offering B: /service-1)"] --> sdk_tooling;
    sdk_tooling["SDK Generation Tooling (Auth, low-level comms, Generator Templates)"] --> sdk_api_docs["SDK API Docs"];
    sdk_tooling --> sdk_package["SDK Package"];
    sdk_api_docs --> customer_docs["Consumer Docs"];
    sdk_package --> package_index["Package Repository"];
{{</mermaid>}}

As you can see everything in this diagram flows from the API specification document which should be considered the *source of truth*, that being said there is still plenty of work and tooling required to get to a polished consumer UX beyond just writing an API specification document.

- API Documentation Generator: [ReDoc](https://github.com/Redocly/redoc)
- Curated Consumer Documentation: [Hugo](https://github.com/gohugoio/hugo)
- SDK Generator: [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator)

Thankfully there is open-source tooling which is available for use, you just have to pick a tool for the problem and hope that when you hit a blocker you will have used it and understand it enough to be able to contribute changes back... easier said than done!