import inspect
import io
from typing import Callable
from PIL import Image
from pyppeteer.page import Page, ElementHandle
from .get_browser import get_browser_page_async

async def web_screenshot_async(
        url: str, 
        *, 
        action: Callable[[Page], None] = None | ElementHandle, 
        executable_path: str = None,
        width: int = 0,
        height: int = 0,
        # pyppeteer.page.Page.screenshot options
        options: dict = {'fullPage': True }) -> Image.Image:
    
    page, browser = await get_browser_page_async(executable_path, width = width, height = height)
    
    # Go to the specified URL
    await page.goto(url)
    screenshot_element: ElementHandle = None
    if action:
        if inspect.iscoroutinefunction(action):
            screenshot_element = await action(page)
        else:
            screenshot_element = action(page)
    # Take a screenshot and get the image bytes
    screenshot_bytes = await (screenshot_element or page).screenshot(options)
    # Close the browser
    await browser.close()
    # Convert the bytes to a PIL Image
    image = Image.open(io.BytesIO(screenshot_bytes))
    return image