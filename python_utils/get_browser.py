import shutil
from typing import Any, Callable, Coroutine
from playwright.async_api import Browser, Page, async_playwright, Playwright

async def get_browser_async(p: Playwright, executable_path: str = None, *, headless = True, incognito = False) -> Browser:
    executable_path = executable_path or\
                    shutil.which("google-chrome") or\
                    shutil.which("chromium-browser") or\
                    shutil.which("chromium")
    
    browser = await p.chromium.launch(
        headless=headless,
        executable_path=executable_path,
        args=["--disable-web-security"] + (['--incognito'] if incognito else [])
    )
    return browser

async def get_browser_page_async(
        executable_path: str = None,
        width: int = 0,
        height: int = 0,
        *,
        playwright: Playwright = None,
        headless: bool = True,
        incognito = False) -> tuple[Page, Callable[[], Coroutine[Any, Any, None]]]:
    playwright = await async_playwright().start()
    browser = await get_browser_async(playwright, executable_path, headless=headless, incognito=incognito)
    context = await browser.new_context(ignore_https_errors=True)
    page = await context.new_page()
    viewport = { 
        "width": width or page.viewport_size["width"], 
        "height": height or page.viewport_size["height"]
    }
    await page.set_viewport_size(viewport_size=viewport)
    async def close_playwright():
        # Close resources manually
        await page.close()    # Close the page
        await context.close() # Close the browser context
        await browser.close() # Close the browser
        await playwright.stop() # Stop Playwright
    return page, close_playwright