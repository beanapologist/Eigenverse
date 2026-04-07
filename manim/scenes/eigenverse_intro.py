"""
Eigenverse Core Constraints Animation
--------------------------------------
Visualises the three minimal primitives that uniquely determine the
Eigenverse structure, working outward to the critical eigenvalue μ,
its 8-cycle orbit, the coherence function C(r), and the silver ratio δS.

Run locally:
    manim -pql eigenverse_intro.py EigenverseIntro
"""

import numpy as np
from manim import (
    # Scenes
    Scene,
    # Mobjects
    Axes,
    Circle,
    Dot,
    Arrow,
    Line,
    DashedLine,
    Arc,
    MathTex,
    Text,
    VGroup,
    # Animations
    Write,
    Create,
    FadeIn,
    FadeOut,
    GrowArrow,
    DrawBorderThenFill,
    # Directions
    UP, DOWN, LEFT, RIGHT,
    UR, UL, DR,
    # Colours
    YELLOW, GOLD, BLUE_B,
    GREEN_B, TEAL_B,
    RED_B, ORANGE,
    WHITE, GREY_B, LIGHT_GREY,
    # Utilities
    PI,
    color_gradient,
)

# ── Project colour palette ──────────────────────────────────────────────────
MU_COLOR      = GOLD          # μ = exp(i·3π/4)
ETA_COLOR     = TEAL_B        # η = 1/√2
CIRCLE_COLOR  = BLUE_B        # unit circle
BALANCE_COLOR = GREEN_B       # balance line −Re = Im
COHERENCE_COLOR = ORANGE      # coherence curve C(r)
AXIOM_COLORS  = [BLUE_B, GREEN_B, ORANGE]

# ── Numerical constants ─────────────────────────────────────────────────────
ETA   = 1.0 / np.sqrt(2)            # η  ≈ 0.7071
MU_RE = -ETA                        # Re(μ) = −η
MU_IM =  ETA                        # Im(μ) = +η
THETA = 3 * PI / 4                  # 135°


def coherence(r: float) -> float:
    """C(r) = 2r / (1 + r²)"""
    return 2 * r / (1 + r ** 2)


class EigenverseIntro(Scene):
    """
    Narrative structure
    ───────────────────
    §0  Title card
    §1  Three axioms introduced side-by-side
    §2  Complex plane — draw unit circle (Axiom 1)
    §3  Add balance line −Re = Im (Axiom 2) → isolate Q2 sector
    §4  Intersection forced to μ (unique solution)
    §5  8-cycle orbit of μ revealed
    §6  Coherence function C(r) — Axiom 3 + fixed-point η
    §7  Outward cascade: δS, physics constants, closing identity
    """

    # ────────────────────────────────────────────────────────────────────────
    def construct(self):
        self._title_card()
        self._three_axioms()
        self._unit_circle()
        self._balance_line()
        self._mu_forced()
        self._eight_cycle()
        self._coherence_closure()
        self._closing_cascade()

    # ── §0  Title card ───────────────────────────────────────────────────────
    def _title_card(self):
        title = Text("Eigenverse", font_size=72, color=MU_COLOR,
                     weight="BOLD")
        tagline = Text(
            "The unique observer-consistent mathematical universe",
            font_size=26, color=LIGHT_GREY,
        )
        tagline.next_to(title, DOWN, buff=0.45)
        group = VGroup(title, tagline).move_to(ORIGIN)

        self.play(Write(title, run_time=1.4))
        self.play(FadeIn(tagline, shift=UP * 0.3, run_time=0.9))
        self.wait(1.8)
        self.play(FadeOut(group))

    # ── §1  Three axioms ─────────────────────────────────────────────────────
    def _three_axioms(self):
        header = Text("3 Core Constraints", font_size=40, color=WHITE,
                      weight="BOLD")
        header.to_edge(UP, buff=0.5)

        axioms_data = [
            (AXIOM_COLORS[0],
             r"\textbf{Axiom 1}",
             r"\mathrm{Re}(z)^2 + \mathrm{Im}(z)^2 = 1",
             "Energy conservation"),
            (AXIOM_COLORS[1],
             r"\textbf{Axiom 2}",
             r"-\mathrm{Re}(z) = \mathrm{Im}(z),\quad \mathrm{Re}(z)<0",
             "Directed balance"),
            (AXIOM_COLORS[2],
             r"\textbf{Axiom 3}",
             r"C(r) = \frac{2r}{1+r^2},\quad C\!\left(1+\tfrac{1}{\eta}\right)=\eta",
             "Coherence closure"),
        ]

        boxes = VGroup()
        for i, (col, label_tex, eq_tex, desc_str) in enumerate(axioms_data):
            lbl  = MathTex(label_tex, font_size=30, color=col)
            eq   = MathTex(eq_tex,   font_size=24, color=WHITE)
            desc = Text(desc_str,    font_size=20, color=col)
            box  = VGroup(lbl, eq, desc).arrange(DOWN, buff=0.2, center=True)
            boxes.add(box)

        boxes.arrange(RIGHT, buff=0.7)
        boxes.next_to(header, DOWN, buff=0.6)

        self.play(Write(header))
        for i, box in enumerate(boxes):
            self.play(FadeIn(box, shift=UP * 0.25, run_time=0.7))
        self.wait(2.0)

        converge_tex = MathTex(
            r"\Downarrow",
            font_size=52, color=MU_COLOR,
        ).next_to(boxes, DOWN, buff=0.4)
        unique_tex = MathTex(
            r"\mu = e^{i \cdot 3\pi/4} \text{ is the UNIQUE solution}",
            font_size=32, color=MU_COLOR,
        ).next_to(converge_tex, DOWN, buff=0.3)

        self.play(Write(converge_tex))
        self.play(Write(unique_tex))
        self.wait(1.8)
        self.play(FadeOut(VGroup(header, boxes, converge_tex, unique_tex)))

    # ── §2  Unit circle (Axiom 1) ────────────────────────────────────────────
    def _unit_circle(self):
        self.axes, self.plane_group = self._make_plane()
        self.play(FadeIn(self.plane_group, run_time=0.8))

        # Axiom 1 label
        ax1 = MathTex(
            r"\mathrm{Re}^2 + \mathrm{Im}^2 = 1",
            font_size=28, color=CIRCLE_COLOR,
        ).to_corner(UR, buff=0.5)
        ax1_head = Text("Axiom 1 ·", font_size=20, color=CIRCLE_COLOR)
        ax1_head.next_to(ax1, UP, buff=0.05, aligned_edge=LEFT)

        circle = Circle(
            radius=self._r(1.0),
            color=CIRCLE_COLOR,
            stroke_width=2.8,
        ).move_to(self.axes.c2p(0, 0))

        self.play(Write(ax1_head), Write(ax1))
        self.play(Create(circle, run_time=1.4))
        self.wait(0.8)

        self.circle = circle
        self.ax1_label = VGroup(ax1_head, ax1)

    # ── §3  Balance line (Axiom 2) ───────────────────────────────────────────
    def _balance_line(self):
        # line  −Re = Im  →  Im = −Re  →  y = −x
        x_start, x_end = -1.5, 1.5
        start_pt = self.axes.c2p(x_start, -x_start)
        end_pt   = self.axes.c2p(x_end,   -x_end)
        balance_line = Line(start_pt, end_pt,
                            color=BALANCE_COLOR, stroke_width=2.5)

        ax2 = MathTex(
            r"-\mathrm{Re}(z) = \mathrm{Im}(z)",
            font_size=28, color=BALANCE_COLOR,
        ).to_corner(UL, buff=0.5)
        ax2_head = Text("Axiom 2 ·", font_size=20, color=BALANCE_COLOR)
        ax2_head.next_to(ax2, UP, buff=0.05, aligned_edge=LEFT)

        sector_label = MathTex(
            r"\mathrm{Re}(z)<0 \;\Rightarrow\; \text{Q2}",
            font_size=22, color=BALANCE_COLOR,
        ).next_to(ax2, DOWN, buff=0.15)

        self.play(Write(ax2_head), Write(ax2))
        self.play(Create(balance_line, run_time=1.1))
        self.play(FadeIn(sector_label, shift=RIGHT * 0.2))
        self.wait(0.8)

        self.balance_line = balance_line
        self.ax2_label    = VGroup(ax2_head, ax2, sector_label)

    # ── §4  μ uniquely forced ────────────────────────────────────────────────
    def _mu_forced(self):
        # Dashed lines to coordinate
        mu_pt = self.axes.c2p(MU_RE, MU_IM)
        re_pt = self.axes.c2p(MU_RE, 0)
        im_pt = self.axes.c2p(0,     MU_IM)

        dash_re = DashedLine(mu_pt, re_pt, color=GREY_B, stroke_width=1.6)
        dash_im = DashedLine(mu_pt, im_pt, color=GREY_B, stroke_width=1.6)

        mu_dot = Dot(mu_pt, color=MU_COLOR, radius=0.14)

        # Coordinate labels
        eta_re = MathTex(r"-\eta", font_size=22, color=ETA_COLOR)
        eta_re.next_to(re_pt, DOWN, buff=0.12)
        eta_im = MathTex(r"+\eta", font_size=22, color=ETA_COLOR)
        eta_im.next_to(im_pt, RIGHT, buff=0.12)

        mu_label = MathTex(
            r"\mu = -\eta + i\eta",
            font_size=28, color=MU_COLOR,
        )
        mu_label.next_to(mu_pt, UL, buff=0.18)

        theta_label = MathTex(r"135°", font_size=22, color=MU_COLOR)
        theta_arc   = Arc(
            radius=self._r(0.32),
            start_angle=0,
            angle=THETA,
            color=MU_COLOR,
            stroke_width=1.8,
        ).move_arc_center_to(self.axes.c2p(0, 0))
        theta_label.next_to(self.axes.c2p(0.15, 0.25), UR, buff=0.0)

        forced_box = MathTex(
            r"\Rightarrow\; \mu = e^{\,i\cdot 3\pi/4}",
            font_size=32, color=MU_COLOR,
        ).to_edge(DOWN, buff=0.55)

        self.play(Create(dash_re), Create(dash_im))
        self.play(
            DrawBorderThenFill(mu_dot),
            FadeIn(eta_re), FadeIn(eta_im),
            run_time=0.9,
        )
        self.play(Write(mu_label))
        self.play(Create(theta_arc), Write(theta_label))
        self.play(Write(forced_box))
        self.wait(1.8)

        self.mu_dot     = mu_dot
        self.mu_label   = mu_label
        self.forced_box = forced_box
        self._mu_extras = VGroup(dash_re, dash_im, eta_re, eta_im,
                                 theta_arc, theta_label)

    # ── §5  8-cycle orbit ────────────────────────────────────────────────────
    def _eight_cycle(self):
        # Clear axiom labels + forced box to make room
        self.play(
            FadeOut(self.ax1_label),
            FadeOut(self.ax2_label),
            FadeOut(self.forced_box),
            FadeOut(self._mu_extras),
        )

        cycle_header = Text("8-Cycle Orbit of μ", font_size=32, color=MU_COLOR,
                             weight="BOLD")
        cycle_header.to_edge(UP, buff=0.35)
        self.play(FadeIn(cycle_header, shift=DOWN * 0.2))

        orbit_label = MathTex(r"\mu^8 = 1", font_size=28, color=MU_COLOR)
        orbit_label.to_corner(UR, buff=0.5)
        self.play(Write(orbit_label))

        dots     = []
        dot_lbls = []
        n = 8
        colors = color_gradient([MU_COLOR, TEAL_B, BLUE_B, GREEN_B,
                                  MU_COLOR], n)
        for k in range(n):
            angle = THETA * (k + 1)   # μ^k for k=1..8
            rx    = np.cos(angle)
            ry    = np.sin(angle)
            pt    = self.axes.c2p(rx, ry)
            d     = Dot(pt, color=colors[k], radius=0.10)
            lbl   = MathTex(rf"\mu^{{{k+1}}}", font_size=18, color=colors[k])
            # offset label away from centre
            offset_dir = np.array([rx, ry, 0])
            lbl.move_to(pt + offset_dir * 0.38)
            dots.append(d)
            dot_lbls.append(lbl)

        orbit_dots = VGroup(*dots)
        orbit_lbl_group = VGroup(*dot_lbls)

        # Draw polygon connecting orbit points
        orbit_pts  = [self.axes.c2p(np.cos(THETA*(k+1)),
                                     np.sin(THETA*(k+1))) for k in range(n)]
        orbit_poly = VGroup(*[
            Line(orbit_pts[i], orbit_pts[(i+1) % n],
                 color=GREY_B, stroke_width=1.2)
            for i in range(n)
        ])

        self.play(Create(orbit_poly, run_time=1.6))
        for d, lbl in zip(dots, dot_lbls):
            self.play(
                DrawBorderThenFill(d, run_time=0.25),
                FadeIn(lbl, run_time=0.25),
            )
        self.wait(2.0)

        # Emphasise μ^8 = μ^0 = 1
        highlight = Dot(self.axes.c2p(1, 0), color=YELLOW, radius=0.16)
        identity_label = MathTex(r"\mu^8 = 1", font_size=26, color=YELLOW)
        identity_label.next_to(self.axes.c2p(1, 0), DR, buff=0.15)
        self.play(
            DrawBorderThenFill(highlight),
            Write(identity_label),
        )
        self.wait(1.5)

        self.play(
            FadeOut(orbit_poly),
            FadeOut(orbit_dots),
            FadeOut(orbit_lbl_group),
            FadeOut(highlight),
            FadeOut(identity_label),
            FadeOut(orbit_label),
            FadeOut(cycle_header),
        )

    # ── §6  Coherence closure (Axiom 3) ─────────────────────────────────────
    def _coherence_closure(self):
        # We leave the complex plane visible but add a second mini-axes on
        # the right side for C(r).

        # Fade out complex plane, replace with side-by-side layout
        self.play(
            FadeOut(self.plane_group),
            FadeOut(self.circle),
            FadeOut(self.balance_line),
            FadeOut(self.mu_dot),
            FadeOut(self.mu_label),
        )

        # ── Coherence plot ───────────────────────────────────────────────────
        coh_axes = Axes(
            x_range=[0, 3.2, 1],
            y_range=[0, 1.1, 0.5],
            x_length=5.5,
            y_length=3.5,
            axis_config={"color": GREY_B, "stroke_width": 1.8,
                         "include_tip": True},
        ).shift(RIGHT * 1.0 + DOWN * 0.2)

        x_label = MathTex("r", font_size=26, color=GREY_B)
        x_label.next_to(coh_axes.x_axis.get_end(), RIGHT, buff=0.15)
        y_label = MathTex("C(r)", font_size=26, color=COHERENCE_COLOR)
        y_label.next_to(coh_axes.y_axis.get_end(), UP, buff=0.1)

        curve = coh_axes.plot(
            lambda r: coherence(r),
            x_range=[0.02, 3.15],
            color=COHERENCE_COLOR,
            stroke_width=2.8,
        )

        ax3_label = MathTex(
            r"C(r) = \frac{2r}{1+r^2}",
            font_size=30, color=COHERENCE_COLOR,
        ).to_corner(UL, buff=0.5)
        ax3_head = Text("Axiom 3 ·", font_size=20, color=COHERENCE_COLOR)
        ax3_head.next_to(ax3_label, UP, buff=0.05, aligned_edge=LEFT)

        self.play(
            FadeIn(coh_axes),
            Write(x_label), Write(y_label),
            Write(ax3_head), Write(ax3_label),
        )
        self.play(Create(curve, run_time=1.6))

        # ── Maximum at r=1, C(1)=1 ──────────────────────────────────────────
        max_dot = Dot(coh_axes.c2p(1, 1), color=ETA_COLOR, radius=0.10)
        max_line_v = DashedLine(
            coh_axes.c2p(1, 0), coh_axes.c2p(1, 1),
            color=ETA_COLOR, stroke_width=1.5,
        )
        max_line_h = DashedLine(
            coh_axes.c2p(0, 1), coh_axes.c2p(1, 1),
            color=ETA_COLOR, stroke_width=1.5,
        )
        max_label = MathTex(r"C(1)=1", font_size=20, color=ETA_COLOR)
        max_label.next_to(coh_axes.c2p(1, 1), UR, buff=0.12)

        self.play(
            Create(max_line_v), Create(max_line_h),
            DrawBorderThenFill(max_dot),
            Write(max_label),
        )
        self.wait(0.8)

        # ── Fixed-point η: C(1+1/η) = η  (Axiom 3 closure) ─────────────────
        silver_scale = 1.0 + 1.0 / ETA   # ≈ 2.414 = δS
        eta_val      = ETA                # ≈ 0.7071

        fp_dot_r = Dot(coh_axes.c2p(silver_scale, eta_val),
                       color=MU_COLOR, radius=0.12)
        fp_line_v = DashedLine(
            coh_axes.c2p(silver_scale, 0),
            coh_axes.c2p(silver_scale, eta_val),
            color=MU_COLOR, stroke_width=1.5,
        )
        fp_line_h = DashedLine(
            coh_axes.c2p(0, eta_val),
            coh_axes.c2p(silver_scale, eta_val),
            color=MU_COLOR, stroke_width=1.5,
        )
        delta_s_label = MathTex(r"\delta_S=1+\sqrt{2}", font_size=18,
                                 color=MU_COLOR)
        delta_s_label.next_to(coh_axes.c2p(silver_scale, 0), DOWN, buff=0.15)
        eta_axis_label = MathTex(r"\eta", font_size=20, color=MU_COLOR)
        eta_axis_label.next_to(coh_axes.c2p(0, eta_val), LEFT, buff=0.12)

        fp_eq = MathTex(
            r"C\!\left(\delta_S\right) = \eta = \tfrac{1}{\sqrt{2}}",
            font_size=26, color=MU_COLOR,
        ).next_to(ax3_label, DOWN, buff=0.5)

        self.play(
            Create(fp_line_v), Create(fp_line_h),
            DrawBorderThenFill(fp_dot_r),
            Write(delta_s_label), Write(eta_axis_label),
        )
        self.play(Write(fp_eq))
        self.wait(2.2)

        self.play(FadeOut(VGroup(
            coh_axes, x_label, y_label, curve,
            ax3_head, ax3_label,
            max_dot, max_line_v, max_line_h, max_label,
            fp_dot_r, fp_line_v, fp_line_h,
            delta_s_label, eta_axis_label, fp_eq,
        )))

    # ── §7  Closing cascade ──────────────────────────────────────────────────
    def _closing_cascade(self):
        # Bring back complex plane
        axes, plane_group = self._make_plane(small=True)
        plane_group.shift(LEFT * 3.2)
        circle = Circle(
            radius=self._r(1.0, small=True),
            color=CIRCLE_COLOR, stroke_width=2.0,
        ).move_to(axes.c2p(0, 0))
        mu_pt  = axes.c2p(MU_RE, MU_IM)
        mu_dot = Dot(mu_pt, color=MU_COLOR, radius=0.13)
        mu_arr = Arrow(
            axes.c2p(0, 0), mu_pt,
            buff=0, color=MU_COLOR, stroke_width=2.2,
        )
        mu_lbl = MathTex(r"\mu", font_size=28, color=MU_COLOR)
        mu_lbl.next_to(mu_pt, UL, buff=0.12)

        self.play(FadeIn(plane_group), Create(circle))
        self.play(GrowArrow(mu_arr), DrawBorderThenFill(mu_dot))
        self.play(Write(mu_lbl))

        # Right side: cascade of derived quantities
        cascade_items = [
            (MU_COLOR,      r"\mu = e^{i\cdot 3\pi/4}",
             "Critical eigenvalue"),
            (ETA_COLOR,     r"\eta = \tfrac{1}{\sqrt{2}}",
             "Observer amplitude"),
            (BALANCE_COLOR, r"\delta_S = 1+\sqrt{2}",
             "Silver ratio"),
            (COHERENCE_COLOR, r"C(\delta_S) = \tfrac{\sqrt{2}}{2}",
             "Coherence at silver scale"),
            (BLUE_B,        r"\mu^{137} = \mu",
             r"137 ≡ 1 (mod 8), phase preserved"),
            (RED_B,         r"\alpha_{\mathrm{FS}} \approx \tfrac{1}{137}",
             "Fine structure constant"),
        ]

        items_group = VGroup()
        for col, eq_str, desc_str in cascade_items:
            eq   = MathTex(eq_str,  font_size=24, color=col)
            desc = Text(desc_str,   font_size=17, color=col)
            row  = VGroup(eq, desc).arrange(RIGHT, buff=0.35)
            items_group.add(row)

        items_group.arrange(DOWN, buff=0.28, aligned_edge=LEFT)
        items_group.shift(RIGHT * 1.5)

        title_right = Text("Derived Results", font_size=26, color=WHITE,
                           weight="BOLD")
        title_right.next_to(items_group, UP, buff=0.3, aligned_edge=LEFT)

        self.play(FadeIn(title_right, shift=DOWN * 0.2))
        for row in items_group:
            self.play(FadeIn(row, shift=RIGHT * 0.2, run_time=0.55))
        self.wait(2.5)

        # ── Final identity ───────────────────────────────────────────────────
        self.play(FadeOut(VGroup(
            plane_group, circle, mu_dot, mu_arr, mu_lbl,
            title_right, items_group,
        )))
        final = MathTex(
            r"\mu^8 = 1 \quad\Longrightarrow\quad"
            r"\text{unique observer-consistent universe}",
            font_size=34, color=MU_COLOR,
        )
        tagline = Text(
            "Eigenverse — machine-checked, zero sorry, zero gaps.",
            font_size=24, color=LIGHT_GREY,
        )
        tagline.next_to(final, DOWN, buff=0.55)
        self.play(Write(final))
        self.play(FadeIn(tagline, shift=UP * 0.2))
        self.wait(3.0)
        self.play(FadeOut(VGroup(final, tagline)))

    # ── Helpers ──────────────────────────────────────────────────────────────
    def _make_plane(self, small: bool = False):
        """Return (axes, display_group) for the complex plane."""
        length = 3.0 if small else 5.0
        axes = Axes(
            x_range=[-1.6, 1.6, 1],
            y_range=[-1.6, 1.6, 1],
            x_length=length,
            y_length=length,
            axis_config={
                "color": GREY_B,
                "stroke_width": 1.6,
                "include_tip": True,
                "tip_length": 0.18,
            },
        )
        x_lbl = MathTex(r"\mathrm{Re}", font_size=20 if small else 24,
                         color=GREY_B)
        y_lbl = MathTex(r"\mathrm{Im}", font_size=20 if small else 24,
                         color=GREY_B)
        x_lbl.next_to(axes.x_axis.get_end(), RIGHT, buff=0.1)
        y_lbl.next_to(axes.y_axis.get_end(), UP,    buff=0.1)
        group = VGroup(axes, x_lbl, y_lbl)
        return axes, group

    def _r(self, unit_val: float, small: bool = False) -> float:
        """Convert from unit-circle radius to scene units."""
        # Axes x_range is [-1.6, 1.6] over x_length units
        length = 3.0 if small else 5.0
        return unit_val * (length / 3.2)
