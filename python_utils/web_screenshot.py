import inspect
import io
from typing import Callable, Literal
from PIL import Image
from pyppeteer.page import Page, ElementHandle
from .get_browser import get_browser_page_async

async def web_screenshot_async(
        url: str, 
        *, 
        action: Callable[[Page], None | ElementHandle] = None, 
        executable_path: str = None,
        width: int = 0,
        height: int = 0,
        # pyppeteer.page.Page.screenshot options
        screenshot_options: dict = {'fullPage': True },
        crop_options: dict[Literal['left', 'top', 'right', 'bottom'], int | None] | None = None,
        resize_options: dict[Literal['size', 'quality', 'optimize'], int | None] | None = None,) -> Image.Image:
    
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
    screenshot_bytes = await (screenshot_element or page).screenshot(screenshot_options)
    # Close the browser
    await browser.close()
    # Convert the bytes to a PIL Image
    image = Image.open(io.BytesIO(screenshot_bytes))
    crop_options = crop_options or {}
    crop_cordinates = (
        crop_options.get('left', 0), 
        crop_options.get('top', 0), 
        crop_options.get('right', image.size[0]), 
        crop_options.get('bottom', image.size[1]))
    image = image.crop(crop_cordinates)
    # RESIZE THE IMAGE
    resize_options_size = (resize_options or {}).get('size', 1)
    if resize_options_size < 1:
        # Resize the image
        resized_img = image.resize(
            (int(image.size[0] * resize_options_size), 
             int(image.size[1] * resize_options_size)))
        # Create a byte stream
        byte_stream = io.BytesIO()
        # Save the image to the byte stream with optimization
        resize_options_optimize = (resize_options or {}).get('optimize', True)
        resize_options_quality = (resize_options or {}).get('quality', 85)
        resized_img.save(
            byte_stream, 
            format='JPEG', 
            optimize=resize_options_optimize, 
            quality=resize_options_quality)
        # Move to the start of the stream
        byte_stream.seek(0)
        # Reopen the optimized image from the byte stream
        image = Image.open(byte_stream)
    return image