#Replace objectionable language with kittens.
#This is just an example, it's far from exhaustive.
import re

seven_words = re.compile(
  r"\Wfrak\W|\Wsmeg\W|\Wjoojooflop\W|\Wswut\W|\Wshazbot\W|\Wdoh\W|\Wgorram\W|\Wbelgium\W",
  re.IGNORECASE)

def run(content):
    return seven_words.sub(" kitten ", content)
