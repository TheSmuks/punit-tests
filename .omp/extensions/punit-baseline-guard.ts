import type { ExtensionAPI } from '@oh-my-pi/pi-coding-agent';

// Baseline: 130 passed, 4 skipped. Update when test count changes intentionally.
const EXPECTED_PASSED = 130;
const EXPECTED_SKIPPED = 4;

export default function (pi: ExtensionAPI): void {
  pi.on('tool_result', async (event) => {
    const output = String(event.output ?? '');
    if (!output) return;

    // Parse test run summary from pike -M . run_tests.pike output
    const match = output.match(/(\d+) passed.*?(\d+) skipped/);
    if (!match) return;

    const passed = parseInt(match[1], 10);
    const skipped = parseInt(match[2], 10);

    if (passed !== EXPECTED_PASSED || skipped !== EXPECTED_SKIPPED) {
      pi.injectMessage(
        `Baseline shifted: ${passed} passed, ${skipped} skipped ` +
        `(expected ${EXPECTED_PASSED} passed, ${EXPECTED_SKIPPED} skipped). ` +
        `Update AGENTS.md and tests/AGENTS.md baselines if intentional.`,
      );
    }
  });

  pi.on('tool_call', async (event) => {
    if (event.toolName !== 'edit') return;
    const filePath = String(
      (event.input as Record<string, unknown>).path ?? '',
    );
    if (
      filePath.endsWith('AGENTS.md') &&
      !filePath.includes('.omp/') &&
      !filePath.includes('PUnit.pmod/') &&
      !filePath.includes('tests/')
    ) {
      const content = String(
        (event.input as Record<string, unknown>).content ?? '',
      );
      if (content.includes('passed') && content.includes('skipped')) {
        pi.injectMessage(
          'Editing AGENTS.md baseline. Run `pike -M . run_tests.pike tests/` ' +
          'first to confirm the new count is correct.',
        );
      }
    }
  });
}
