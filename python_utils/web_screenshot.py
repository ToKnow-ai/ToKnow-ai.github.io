import inspect
import io
from typing import Callable
from PIL import Image
from playwright.async_api import Page, ElementHandle, async_playwright
from .get_browser import get_browser_page_async

async def web_screenshot_async(
        url: str, 
        *, 
        action: Callable[[Page], None | ElementHandle] = None, 
        executable_path: str = None,
        width: int = 0,
        height: int = 0,
        screenshot_options: dict = None,
        crop_options: dict[str, int | None] | None = None) -> Image.Image:
    
    async with async_playwright() as playwright:
        page, close_playwright = await get_browser_page_async(
            executable_path=executable_path, width=width, height=height, playwright=playwright)
        await page.goto(url)
        screenshot_element = None
        if action:
            if inspect.iscoroutinefunction(action):
                screenshot_element = await action(page)
            else:
                screenshot_element = action(page)
                
        screenshot_options = screenshot_options or {}
        screenshot_bytes = await (screenshot_element or page).screenshot(**screenshot_options)
        
        await close_playwright()
        
        image = Image.open(io.BytesIO(screenshot_bytes))
        
        crop_options = crop_options or {}
        crop_coordinates = (
            crop_options.get('left', 0), 
            crop_options.get('top', 0), 
            crop_options.get('right', image.size[0]), 
            crop_options.get('bottom', image.size[1]))
        image = image.crop(crop_coordinates)
        return image