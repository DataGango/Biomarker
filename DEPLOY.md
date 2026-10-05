# Publish the site with GitHub Pages

This folder is a self-contained static site. It includes the cited research paper and PDF, the downloaded infographic, trial dataset, and charts. The diabetes-trial analysis is explicitly separated from the childhood-cancer evidence. Local copies of full ACS/NCI pages and the ACS biomarker brochure remain local-only; public references link to the original publishers.

## Publish

1. Create a new public GitHub repository for this website, named `childhood-cancer-field-guide` (or another name you choose).
2. From this folder, initialize Git, commit the site files, add the new repository as `origin`, and push the `biomarker` branch. The Pages workflow is configured to deploy from `biomarker` (and `main`). Do not add local-only source extracts; `.gitignore` excludes them.
3. In the repository, open **Settings → Pages** and select **GitHub Actions** as the build and deployment source.
4. Open the **Actions** tab and allow the workflow to finish. GitHub will provide the public Pages URL in the deployment summary.
5. Open the Facebook Page settings and add that public URL to its website field. The site already links back to the supplied Facebook Page.

The workflow publishes only the static site, paper, CSV, and chart assets; it does not publish the Python analysis script or locally mirrored ACS/NCI material. Never add credentials, tokens, or a `.env` file to the repository.

## Local preview

From this folder, run:

```sh
python3 -m http.server 8768 --bind 127.0.0.1
```

Then open <http://127.0.0.1:8768/>. Localhost URLs work only on this computer and are not suitable for the Facebook Page website field.
