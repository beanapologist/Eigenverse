"""
Eigenverse Introduction Animation
-----------------------------------
Demonstrates eigenvalues and eigenvectors using Manim.

Run locally:
    manim -pql eigenverse_intro.py EigenverseIntro
"""

from manim import (
    Scene,
    Matrix,
    MathTex,
    Text,
    Arrow,
    VGroup,
    Write,
    Create,
    Transform,
    FadeIn,
    FadeOut,
    UP,
    DOWN,
    LEFT,
    RIGHT,
    YELLOW,
    BLUE,
    GREEN,
    WHITE,
    config,
)


class EigenverseIntro(Scene):
    """Animates the concept of eigenvalues and eigenvectors for a 2×2 matrix."""

    def construct(self):
        # ── Title ──────────────────────────────────────────────────────────────
        title = Text("Eigenverse", font_size=56, color=YELLOW)
        subtitle = Text("Eigenvalues & Eigenvectors", font_size=32, color=WHITE)
        subtitle.next_to(title, DOWN, buff=0.4)

        self.play(Write(title))
        self.play(FadeIn(subtitle))
        self.wait(1.5)
        self.play(FadeOut(title), FadeOut(subtitle))

        # ── Matrix definition ──────────────────────────────────────────────────
        matrix_label = MathTex(r"A = ", font_size=44)
        matrix = Matrix([[2, 1], [1, 2]], element_alignment_corner=DOWN + LEFT)
        matrix_group = VGroup(matrix_label, matrix).arrange(RIGHT, buff=0.2)
        matrix_group.move_to(UP * 2)

        self.play(Write(matrix_label), Create(matrix))
        self.wait(1)

        # ── Characteristic equation ────────────────────────────────────────────
        char_eq = MathTex(
            r"\det(A - \lambda I) = 0",
            font_size=40,
            color=BLUE,
        )
        char_eq.next_to(matrix_group, DOWN, buff=0.8)
        self.play(Write(char_eq))
        self.wait(1)

        # ── Eigenvalue solutions ───────────────────────────────────────────────
        eigenvalues = MathTex(
            r"\lambda_1 = 1, \quad \lambda_2 = 3",
            font_size=40,
            color=GREEN,
        )
        eigenvalues.next_to(char_eq, DOWN, buff=0.6)
        self.play(Write(eigenvalues))
        self.wait(1)

        # ── Eigenvectors ───────────────────────────────────────────────────────
        eigenvectors = MathTex(
            r"\mathbf{v}_1 = \begin{pmatrix}1\\-1\end{pmatrix}, \quad"
            r"\mathbf{v}_2 = \begin{pmatrix}1\\1\end{pmatrix}",
            font_size=38,
            color=WHITE,
        )
        eigenvectors.next_to(eigenvalues, DOWN, buff=0.6)
        self.play(Write(eigenvectors))
        self.wait(2)

        # ── Closing equation A v = λ v ─────────────────────────────────────────
        closing = MathTex(
            r"A\mathbf{v} = \lambda\mathbf{v}",
            font_size=52,
            color=YELLOW,
        )
        self.play(
            FadeOut(matrix_group),
            FadeOut(char_eq),
            FadeOut(eigenvalues),
            FadeOut(eigenvectors),
        )
        self.play(Write(closing))
        self.wait(2)
        self.play(FadeOut(closing))
