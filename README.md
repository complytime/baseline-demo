# baseline-demo

This repository provides an demonstration on how to use the compliance-to-policy project to automate evidence generation and collection to
demonstrate adherence to the [OSPS Baseline](https://baseline.openssf.org/versions/2025-02-25) controls

# Overview
The `compliance-to-policy` project under OSCAL Compass acts as an overarching translation layer between Compliance-as-Code artifacts (like OSCAL) and native formats for various
policy engines and assessment tools. It provides the framework and core logic for this translation, effectively bridging the gap between high-level compliance
requirements and their concrete implementation as executable policies.
The goal is to provide consistency for reporting and evidence traceability while allowing flexible deployment and support for diverse policy and assessment tools.

# Demo

To demonstrate the evaluation and reporting of a single component, in this case a GitHub Repository, 
the "Evaluate" workflow can be run which will complete the following steps:

1. Transform the Gemara Layers 2, 3, and 4 artifacts into an OSCAL Component Definitions with OSCAL Compass property extensions
2. Provide the OSCAL Component Definition as inputs in the c2pcli with an OPA plugin to provide an OPA bundle that contain all the policies required for evaluation
3. Use `snappy` to retrieve input data from the API and use `opa eval` to evaluate the input data using the policy in the bundle
4. Use the policy results, the OSCAL Component Definition and an OSCAL Catalog transformed from Gemara Layer 1 to produce an OSCAL Assessment Results and Markdown report
5. The Markdown report is available in the job run as a step summary and the policy generated is uploaded as a job artifact

> Note: This demonstration currently does not account for long-term storage of evidence, but provides short-term access to evidence all co-located and links on the GitHub job.
