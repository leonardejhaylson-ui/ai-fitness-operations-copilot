import { expect, test } from "@playwright/test";

test("renders the repository bootstrap", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "AI Fitness Operations Copilot" })).toBeVisible();
  await expect(page.getByText("Repository bootstrap ready")).toBeVisible();
});
