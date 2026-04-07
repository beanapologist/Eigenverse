# Manim – Mathematical Animations for Eigenverse

This directory contains [Manim](https://www.manim.community/) scripts that
generate mathematical animations for the Eigenverse project.

## Directory layout

```
manim/
├── scenes/          # Manim Python scripts (one scene per file)
│   └── eigenverse_intro.py
├── results/         # Rendered videos and images (git-ignored by default)
├── requirements.txt # Python dependencies
└── README.md        # This file
```

## Prerequisites

- Python 3.9+
- System packages required by Manim (Cairo, Pango, FFmpeg, LaTeX).
  See the [official installation guide](https://docs.manim.community/en/stable/installation.html).

## Quick start

```bash
# 1. Create and activate a virtual environment (recommended)
python -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate

# 2. Install Python dependencies
pip install -r manim/requirements.txt

# 3. Render a scene (low quality for fast preview)
manim -pql manim/scenes/eigenverse_intro.py EigenverseIntro

# 4. Render at high quality
manim -pqh manim/scenes/eigenverse_intro.py EigenverseIntro
```

Rendered files are saved to `manim/media/` by default.  Move or copy the
output files into `manim/results/` to keep them alongside the project.

## Quality flags

| Flag | Resolution | Use case |
|------|-----------|----------|
| `-ql` | 480p 15 fps  | Fast local preview |
| `-qm` | 720p 30 fps  | Medium quality     |
| `-qh` | 1080p 60 fps | Final render       |
| `-qk` | 2160p 60 fps | 4 K render         |

## GitHub Actions

A workflow at `.github/workflows/manim.yml` automatically renders every scene
in `manim/scenes/` when changes are pushed and uploads the resulting videos as
GitHub Actions artifacts.

## Adding a new scene

1. Create a new `.py` file in `manim/scenes/`.
2. Define a class that inherits from `Scene` (or another Manim scene type).
3. Implement the `construct` method with your animation logic.
4. Push your changes – the CI workflow will render the scene automatically.
