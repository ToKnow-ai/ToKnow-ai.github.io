[ToKnow.ai](toknow.ai)

TODO:
Add missing quarto featues for PDF such as:
- description, 
- categories, 
- keywords, 
- center download button (if not ipynb)

To All:
 - Add sources of data (we probably need a special html comment to denote a data source, or special quarto comment!)
 - Add disclaimer link to /terms-of-service
 - Add Packages used and save a requirements.txt
 - And how comes categories in project directory `_metadata.yaml` are not added when displaying a post when other categories have been specified at the file level, but works when file yaml is in a file. Works in home page though


 ADD DISCLEIMER TO THE VERY END OF THE DOCUMENT
 EXPORT NOTEBOOK
 PREVENT RENDERING DRAFT DOCUMENTS
 RENDERING IMAGES IN THE NEW METADATA FORMAT WITHIN NOTEBOOK MARKDOWN - `image:` metadata extracted by `<!-- metadata: image -->` doesnt seem to work.

bibtex citations created with NOTEBOOK filter dont have title!

add counter https://api.visitorbadge.io/api/visitors?path=...
[`ipynb-output: all,none,best`](https://quarto.org/docs/reference/formats/ipynb.html) does not WORK

links to run in deepnote and colab

Opening hugging space iframes (perhaps add ability to add domain to the URL?)
https://stackoverflow.com/a/5697801
https://chromium.googlesource.com/chromium/src/+/master/docs/security/lookalikes/lookalike-domains.md
```json
[
  {
    "relation": ["lookalikes/allowlist"],
    "target": { 
        "namespace": "web", 
        "site": "https://toknow.ai" 
    }
  },
  {
    "relation": ["lookalikes/allowlist"],
    "target": { 
        "namespace": "web", 
        "site": "https://toknow-ai-private-domain-checker.hf.space" 
    }
  }
]
```


SVG IMAGES NOT WORKING FOR PDF despite the claim: <https://quarto.org/docs/prerelease/1.3/pdf.html#remote-images>
![](https://quarto.org/quarto.png)

![](https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg?test.png)