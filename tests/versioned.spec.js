// @ts-check
const { test } = require('@playwright/test');

test('navigate to home page', async ({ page }) => {
  await page.goto('http://localhost:3000/versioned.html');
  await page.waitForLoadState('networkidle');
});

test('navigate to article 1', async ({ page }) => {
  await page.goto('http://localhost:3000/versioned.html?id=1');
  await page.waitForLoadState('networkidle');
});

test('navigate to article 2', async ({ page }) => {
  await page.goto('http://localhost:3000/versioned.html?id=2');
  await page.waitForLoadState('networkidle');
});

test('navigate to article 3', async ({ page }) => {
  await page.goto('http://localhost:3000/versioned.html?id=3');
  await page.waitForLoadState('networkidle');
});