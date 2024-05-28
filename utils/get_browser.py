from pyppeteer import launch
import shutil
from pyppeteer.page import Page
from pyppeteer.browser import Browser

async def get_browser_async(executable_path: str = None) -> Browser:
    executable_path = executable_path or\
                    shutil.which("google-chrome") or\
                    shutil.which("chromium-browser") or\
                    shutil.which("chromium")
    # Launch a new browser instance
    browser = await launch({
        'headless': True, 
        'executablePath': executable_path,
        'args': ["--disable-web-security"],
        'ignoreHTTPSErrors': True })
    return browser

async def get_browser_page_async(
        executable_path: str = None,
        width: int = 0,
        height: int = 0) -> tuple[Page, Browser]:
    browser = await get_browser_async(executable_path)
    
    # Open a new page
    page = await browser.newPage()

    # 0 makes it default height or default width
    await page.setViewport({'width': width, 'height': height})
    return page, browser