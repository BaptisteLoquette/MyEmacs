"""End-to-end verification: taxonomy lookup → pattern selection → code generation → render."""
import yaml
import subprocess
import tempfile
import os
import sys

def test_taxonomy_lookup():
    """Verify taxonomy files are loadable and complete."""
    print("=== Taxonomy Lookup ===")
    for domain in ['physics', 'electronics', 'genai']:
        with open(f'C:/Users/Bapti/docs/superpowers/viz-framework/taxonomy/{domain}.yaml') as f:
            data = yaml.safe_load(f)
        sub_count = len(data['sub_disciplines'])
        concept_count = sum(len(sd['concepts']) for sd in data['sub_disciplines'].values())
        print(f"  {domain}: {sub_count} sub-disciplines, {concept_count} concepts")
    print("  Taxonomy lookup: PASS\n")

def test_patterns_loaded():
    """Verify nine-patterns.yaml is loadable."""
    print("=== Pattern Definitions ===")
    with open('C:/Users/Bapti/docs/superpowers/viz-framework/patterns/nine-patterns.yaml') as f:
        data = yaml.safe_load(f)
    assert len(data['patterns']) == 9
    assert len(data['interaction_tiers']) == 6
    assert len(data['ux_quality_rules']) == 9
    assert len(data['anti_patterns']) == 5
    print("  Patterns: PASS\n")

def test_taxonomy_to_pattern_mapping():
    """Verify a concept maps to correct pattern and framework."""
    print("=== Taxonomy -> Pattern Mapping ===")
    with open('C:/Users/Bapti/docs/superpowers/viz-framework/taxonomy/physics.yaml') as f:
        physics = yaml.safe_load(f)
    concept = physics['sub_disciplines']['electromagnetism']['concepts'][0]
    assert concept['name'] == 'electrostatic_field'
    assert concept['primary_pattern'] == 'vectorfield'
    assert concept['best_framework'] == 'plotly'
    print("  electrostatic_field -> vectorfield -> plotly: PASS\n")

def test_matplotlib_render():
    """Verify matplotlib produces a PNG file."""
    print("=== Matplotlib Render ===")
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
                               capture_output=True, text=True)
        assert result.returncode == 0, f"Matplotlib failed: {result.stderr}"
        assert os.path.exists(os.path.join(tmpdir, 'test_output.png'))
    print("  Matplotlib render: PASS\n")

def test_schemdraw_render():
    """Verify schemdraw produces SVG output."""
    print("=== Schemdraw Render ===")
    code = """
import matplotlib
matplotlib.use('Agg')
import schemdraw
schemdraw.use('matplotlib')
import schemdraw.elements as elm
with schemdraw.Drawing(file='test_circuit.svg') as d:
    elm.Resistor().right().label('1k')
    elm.Ground()
"""
    with tempfile.TemporaryDirectory() as tmpdir:
        script = os.path.join(tmpdir, 'test.py')
        with open(script, 'w') as f:
            f.write(code)
        result = subprocess.run(['python', script], cwd=tmpdir,
                               capture_output=True, text=True)
        assert result.returncode == 0, f"Schemdraw failed: {result.stderr}"
        assert os.path.exists(os.path.join(tmpdir, 'test_circuit.svg'))
    print("  Schemdraw render: PASS\n")

if __name__ == '__main__':
    print("=== Running Verification Suite ===\n")
    test_taxonomy_lookup()
    test_patterns_loaded()
    test_taxonomy_to_pattern_mapping()
    test_matplotlib_render()
    test_schemdraw_render()
    print("=== All tests passed ===")
