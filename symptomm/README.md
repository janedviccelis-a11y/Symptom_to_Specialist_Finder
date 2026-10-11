# Mediora

Mediora provides general guidance on which medical specialties may be relevant
to selected symptoms. It is not a diagnostic tool.

## 3D anatomy viewer

The symptom page renders the Human Atlas BodyParts3D model directly in Mediora's
WebView with Three.js. It does not embed the Atlas website. The app downloads
the model manifest and compressed geometry from the pinned, public
[Human Atlas model release](https://github.com/ashemag/human-atlas/tree/1c38bf35c254a891200d3cedecfd57abebe83d8d/public/models).
Tapping a model structure maps it to a Mediora body area and filters the
related symptom list. An internet connection is required for the first load.

The model data is adapted from BodyParts3D 4.0, © Database Center for Life
Science, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
The Human Atlas source and data preparation are available in the
[Human Atlas repository](https://github.com/ashemag/human-atlas); the viewer
application source is under its [MIT License](https://github.com/ashemag/human-atlas/blob/main/LICENSE).
This is an adult male reference model intended for education, not diagnosis or
treatment. See the [BodyParts3D data license](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/lic.html)
and [dataset information](https://dbarchive.biosciencedbc.jp/en/bodyparts3d/download.html).
