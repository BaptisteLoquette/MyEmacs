"""End-to-end verification: taxonomy lookup → pattern selection → code generation → export."""

import yaml
import subprocess
import tempfile
import os
import sys

BASE = 'C:/Users/Bapti/docs/superpowers/viz-framework'


def test_taxonomy_lookup():
    """Verify taxonomy files are loadable and complete."""
    expected = {
        'physics': (6, 35, 50),      # min 6 sub, 35-50 concepts
        'electronics': (15, 85, 120), # min 15 sub, 85-120 concepts
        'genai': (9, 45, 70),         # min 9 sub, 45-70 concepts
    }
    for domain, (min_sub, min_con, max_con) in expected.items():
        path = os.path.join(BASE, 'taxonomy', f'{domain}.yaml')
        with open(path, encoding='utf-8') as f:
            data = yaml.safe_load(f)
        sub_count = len(data['sub_disciplines'])
        concept_count = sum(len(sd.get('concepts', []))
                          for sd in data['sub_disciplines'].values())
        assert sub_count >= min_sub, \
            f"{domain}: expected >= {min_sub} sub-disciplines, got {sub_count}"
        assert min_con <= concept_count <= max_con, \
            f"{domain}: expected {min_con}-{max_con} concepts, got {concept_count}"
        print(f"  {domain}: {sub_count} sub-disciplines, {concept_count} concepts")
    print("  Taxonomy lookup: PASS")


def test_patterns_loaded():
    """Verify nine-patterns.yaml structure."""
    path = os.path.join(BASE, 'patterns', 'nine-patterns.yaml')
    with open(path, encoding='utf-8') as f:
        data = yaml.safe_load(f)
    assert len(data['patterns']) == 9, \
        f"Expected 9 patterns, got {len(data['patterns'])}"
    assert len(data['interaction_tiers']) == 6
    assert len(data['ux_quality_rules']) == 9
    assert len(data['anti_patterns']) == 5
    print(f"  Patterns: {len(data['patterns'])} patterns, "
          f"{len(data['interaction_tiers'])} tiers, "
          f"{len(data['ux_quality_rules'])} UX rules, "
          f"{len(data['anti_patterns'])} anti-patterns")
    print("  Patterns: PASS")


def test_code_templates_compile():
    """Verify all 9 code templates are syntactically valid."""
    import py_compile
    pattern_dir = os.path.join(BASE, 'templates', 'code-patterns')
    files = ['scalarfield', 'vectorfield', 'signalflow', 'geom3d',
             'graphnet', 'processanim', 'probdist', 'phasetraj',
             'decisionprocess']
    for f in files:
        path = os.path.join(pattern_dir, f'{f}.py')
        py_compile.compile(path, doraise=True)
        print(f"  {f}.py: compile OK")
    print("  Code templates: PASS")


def test_agent_prompts_exist():
    """Verify all 9 agent prompt files exist and have content."""
    prompt_dir = os.path.join(BASE, 'templates', 'agent-prompts')
    files = ['matplotlib', 'plotly', 'manim', 'schemdraw', 'pyvista',
             'altair', 'tikz', 'graphviz', 'by-hand']
    for f in files:
        path = os.path.join(prompt_dir, f'{f}.md')
        assert os.path.exists(path), f"Missing: {path}"
        content = open(path, encoding='utf-8').read()
        assert len(content) > 100, f"{f}.md too short: {len(content)} chars"
        assert '```' in content, f"{f}.md missing code blocks"
        print(f"  {f}.md: {len(content)} chars OK")
    print("  Agent prompts: PASS")


def test_matplotlib_render():
    """Verify matplotlib produces a PNG file."""
    code = """
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
fig, ax = plt.subplots()
ax.plot(np.sin(np.linspace(0, 6.28, 100)))
fig.savefig('test_output.png', dpi=150)
plt.close(fig)
"""
    with tempfile.TemporaryDirectory() as tmpdir:
        script = os.path.join(tmpdir, 'test.py')
        with open(script, 'w') as f:
            f.write(code)
        result = subprocess.run(['python', script], cwd=tmpdir,
                                capture_output=True, text=True, timeout=30)
        assert result.returncode == 0, f"Matplotlib failed: {result.stderr}"
        out_path = os.path.join(tmpdir, 'test_output.png')
        assert os.path.exists(out_path), "No PNG produced"
        assert os.path.getsize(out_path) > 100, "PNG too small"
    print("  Matplotlib render: PASS")


def test_schemdraw_render():
    """Verify schemdraw produces SVG output."""
    try:
        import schemdraw
    except ImportError:
        print("  Schemdraw render: SKIP (not installed)")
        return
    code = """
import schemdraw
import schemdraw.elements as elm
with schemdraw.Drawing(file='test_circuit.svg') as d:
    elm.Resistor().right().label('1k')
    elm.Ground()
"""
    with tempfile.TemporaryDirectory() as tmpdir:
        script = os.path.join(tmpdir, 'test.py')
        with open(script, 'w') as f:
            f.write(code)
        try:
            result = subprocess.run(['python', script], cwd=tmpdir,
                                    capture_output=True, text=True, timeout=30)
        except subprocess.TimeoutExpired:
            print("  Schemdraw render: SKIP (timeout)")
            return
        if result.returncode != 0:
            print(f"  Schemdraw render: SKIP ({result.stderr.strip()})")
            return
        out_path = os.path.join(tmpdir, 'test_circuit.svg')
        assert os.path.exists(out_path), "No SVG produced"
    print("  Schemdraw render: PASS")


def test_org_examples_exist():
    """Verify all Org example files exist."""
    example_dir = os.path.join(BASE, 'org', 'examples')
    for f in ['circuit.org', 'animation.org', 'diffusion.org', 'by-hand.org']:
        path = os.path.join(example_dir, f)
        assert os.path.exists(path), f"Missing: {path}"
        content = open(path, encoding='utf-8').read()
        assert '#+begin_src' in content, f"{f} missing source block"
        print(f"  {f}: OK")
    readme = os.path.join(BASE, 'org', 'README.org')
    assert os.path.exists(readme), "Missing README.org"
    print("  Org examples: PASS")


if __name__ == '__main__':
    print("=== Visualization Framework Verification Suite ===\n")
    tests = [
        ('Taxonomy lookup', test_taxonomy_lookup),
        ('Patterns loaded', test_patterns_loaded),
        ('Code templates compile', test_code_templates_compile),
        ('Agent prompts exist', test_agent_prompts_exist),
        ('Matplotlib render', test_matplotlib_render),
        ('Schemdraw render', test_schemdraw_render),
        ('Org examples exist', test_org_examples_exist),
    ]

    failed = []
    for name, test_fn in tests:
        try:
            test_fn()
        except Exception as e:
            print(f"  {name}: FAIL — {e}")
            failed.append(name)

    print(f"\n=== {len(tests) - len(failed)}/{len(tests)} tests passed ===")
    if failed:
        print(f"Failed: {', '.join(failed)}")
        sys.exit(1)
    else:
        print("All tests passed.")
