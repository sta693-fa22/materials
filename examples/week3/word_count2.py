from mrjob.job import MRJob
import re

class MRWordCount(MRJob):
  def mapper(self, _, line):
    for word in line.split():
      clean_word = re.sub(r'[^\w]', '', word.lower())
      yield(clean_word, 1)

  def reducer(self, word, counts):
    n = sum(counts)
    if n > 5:
      yield(word, n)

if __name__ == '__main__':
  MRWordCount.run()
