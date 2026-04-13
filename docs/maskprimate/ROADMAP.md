# MaskPrimate — Roadmap

Development is organised into four phases. Phase 1 is complete; subsequent phases are ordered by research impact and implementation complexity.

---

## Phase 1 — Foundation (complete)

Core animal pose pipeline, additive to MaskAnyone with no human-mode regressions.

- [x] RTMPose AP-10K integration (17-keypoint animal skeleton, 54 species)
- [x] AP-10K skeleton renderer (`AP10K_PAIRS`, `_render_ap10k_overlay`)
- [x] Frontend dropdown option for AP-10K
- [x] OpenPose disabled (human-only, not relevant for animal workflow)
- [x] RTMPose model weight cache volume-mounted for persistence across rebuilds

---

## Phase 2 — Species-specific models

Extend pose support beyond the generic AP-10K topology to species with higher anatomical specificity.

- [ ] **MacaquePose** — macaque-specific keypoint model; higher precision for *Macaca* species than AP-10K generic skeleton. Relevant where detailed limb and facial landmark data matters.
- [ ] **SuperAnimal (DeepLabCut)** — pretrained on large multi-species dataset; consider as alternative or supplement to AP-10K for cross-species generalisation
- [ ] Evaluate AP-10K vs MacaquePose output quality on target footage; document which model performs better per species/recording condition

---

## Phase 3 — Segmentation quality for field footage

SAM2 out-of-the-box is trained primarily on human and object data. Field footage (occlusion, foliage, motion blur, variable lighting) degrades segmentation quality significantly.

- [ ] **SA-FARI fine-tune** — fine-tune SAM2 on Meta's SA-FARI animal video dataset; expected to substantially improve mask quality on natural-habitat recordings
- [ ] Integrate fine-tuned checkpoint into `sam2/src/segmentation.py` `MODEL_CONFIGS` as `sam2.1_hiera_tiny_safari` (or similar)
- [ ] Expose fine-tuned model in the frontend segmentation model dropdown
- [ ] Benchmark: compare baseline SAM2 vs SA-FARI fine-tune on representative primate footage; quantify mask IoU improvement

---

## Phase 4 — Multi-animal tracking and identity

The current pipeline tracks multiple objects within a video but does not maintain identity consistency when animals cross, occlude each other, or leave and re-enter frame. This is critical for group behaviour studies.

- [ ] Investigate SAM2's built-in multi-object tracking capabilities and their limits with primates
- [ ] Evaluate identity drift across long recordings (>5 min) with 2–4 subjects
- [ ] Explore re-identification strategies to recover tracking after full occlusion
- [ ] Consider integration of animal re-ID models (e.g. HotSpotter, or species-specific approaches) to assign consistent IDs across shots

---

## Open questions

These require research decisions before implementation:

| Question | Why it matters |
|---|---|
| Target species scope | Determines which pose models to prioritise (AP-10K generic vs. species-specific) |
| Lab vs. field footage | Determines urgency of SA-FARI fine-tune (Phase 3) |
| Primary use case: pose extraction vs. anonymisation | Determines skeleton topology requirements and output format needs |
| Desired output format for pose data | JSON (current) sufficient, or need CSV / HDF5 / BIDS-compatible format for downstream behavioural analysis tools? |
| Individual identity protection requirements | Informs depth of anonymisation beyond blurring (e.g. gait normalisation, landmark suppression) |

---

## Out of scope

- Human de-identification (handled by MaskAnyone main branch)
- Real-time / live video processing
- Audio anonymisation for animal vocalisations
