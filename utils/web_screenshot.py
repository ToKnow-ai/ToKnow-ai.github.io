import asyncio
from typing import Callable
from pyppeteer import launch
from pyppeteer.page import Page
from PIL import Image
import io
import nest_asyncio
import shutil
import inspect

nest_asyncio.apply()

async def web_screenshot_async(
        url: str, 
        *, 
        action: Callable[[Page], None] = None, 
        executable_path: str = None) -> Image.Image:
    executable_path = executable_path or\
                    shutil.which("google-chrome") or\
                    shutil.which("chromium-browser") or\
                    shutil.which("chromium")
    # Launch a new browser instance
    browser = await launch(headless=True, executablePath=executable_path)
    # Open a new page
    page = await browser.newPage()

    # Set viewport width and height
    width = 1600  # Specify your desired width
    height = 0  # Setting height to 0 makes it full height
    await page.setViewport({'width': width, 'height': height})
    
    # Go to the specified URL
    await page.goto(url)
    if action:
        if inspect.iscoroutinefunction(action):
            await action(page)
        else:
            action(page)
    # Take a screenshot and get the image bytes
    screenshot_bytes = await page.screenshot({'fullPage': True })
    # Close the browser
    await browser.close()
    # Convert the bytes to a PIL Image
    image = Image.open(io.BytesIO(screenshot_bytes))
    return image

def web_screenshot(
        url: str, 
        *, 
        action: Callable[[Page], None] = None, 
        executable_path: str = None) -> Image.Image:
    return asyncio.run(web_screenshot_async(
        url, 
        action = action, 
        executable_path = executable_path))