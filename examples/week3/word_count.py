from mrjob.job import MRJob
import re

class MRWordCount(MRJob):
  def mapper(self, _, line):
    for word in line.split():
      yield(word, 1)

  def reducer(self, word, counts):
    yield(word, sum(counts))

if __name__ == '__main__':
  MRWordCount.run()
