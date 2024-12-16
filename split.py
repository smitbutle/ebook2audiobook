from ebooklib import epub, ITEM_DOCUMENT
import os
from bs4 import BeautifulSoup

def split_epub_into_epubs(input_epub_path, output_directory, start, end):
    # Read the EPUB file
    # n = 0
    book = epub.read_epub(input_epub_path)

    # Ensure the output directory exists
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # Iterate over each document in the EPUB
    chapter_number = -3
    for item in book.get_items_of_type(ITEM_DOCUMENT):

        if chapter_number <= 0:
            chapter_number += 1
            continue
        
        if chapter_number < start:
            chapter_number += 1
            continue

        new_book = epub.EpubBook()

        soup = BeautifulSoup(item.get_content(), 'html.parser')
        for aside in soup.find_all('aside'):
            aside.decompose()
        for anchor in soup.find_all('a'):
            anchor.replace_with(anchor.get_text())

        # raw_content = raw_content.replace('F**k', 'Fork').replace('f**k', 'fork')


        binary_content = soup.prettify(formatter=None).replace('\n', '&#13;\n').encode('utf-8')
        new_chapter = epub.EpubHtml(
            file_name=f"chapter_{chapter_number}.xhtml",
        )

        new_chapter.set_content(binary_content)
        new_book.add_item(new_chapter)

        new_book.spine = [new_chapter]

        output_file_path = os.path.join(output_directory, f"chapter_{chapter_number}.epub")
        epub.write_epub(output_file_path, new_book)
        print(f"Chapter {chapter_number} saved as {output_file_path}")


        chapter_number += 1

        if chapter_number > end:
            break

    print(f"All chapters have been saved to {output_directory}")

# Example usage
input_epub = 'data/input.epub'  # Replace with your EPUB file path
output_dir = 'output_epubs'  # Replace with your desired output directory
split_epub_into_epubs(input_epub, output_dir, start= 200, end= 210)
