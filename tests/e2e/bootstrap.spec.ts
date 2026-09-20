import { expect, test } from '@playwright/test';

test('renders the authentication entry point without configured secrets', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL(/\/login$/);
  await expect(page.getByRole('heading', { name: 'Acesse sua conta' })).toBeVisible();
  await expect(page.getByLabel('E-mail')).toBeVisible();
  await expect(page.getByLabel('Senha')).toBeVisible();
});
