# coding=utf-8
import pandas as pd
from representations.sequentialembedding import SequentialEmbedding

'''
这个脚本用来整理相似度数据框，以便后续导入R分析，以下是输出结果的一个片段示例：
其中attribute是指词对的属性（attribute_1 道德-自我，attribute_2 道德-他人）

        1950      1960       1970       1980       1990   attribute word_1 word_2   word_pair
20 0.0000000 0.0000000 0.00000000 0.00000000 0.00000000 attribute_1   辩护 我们的 辩护-我们的
21 0.1546041 0.2577005 0.12749325 0.15079959 0.11061748 attribute_1   支持     我     支持-我
22 0.2013293 0.2148688 0.04841036 0.13504367 0.01311489 attribute_1   支持   自己   支持-自己
23 0.3099849 0.3022226 0.18973643 0.09597351 0.15905641 attribute_1   支持   我们   支持-我们
24 0.0000000 0.0000000 0.00000000 0.00000000 0.00000000 attribute_1   支持   我的   支持-我的
25 0.0000000 0.0000000 0.00000000 0.00000000 0.00000000 attribute_1   支持 我们的 支持-我们的
'''

embeddings = SequentialEmbedding.load("../embeddings/chinese_sgns", range(1950, 2000, 10))

dictionary = pd.read_csv("../my_analysis/dictionary.csv")

panel_data = pd.DataFrame([])

for communion_word in dictionary.loc[dictionary["communion"].notnull(), "communion"]:
    communion_word = unicode(communion_word, "utf-8")

    for attribute_1_word in dictionary.loc[dictionary["attribute_1"].notnull(), "attribute_1"]:
        attribute_1_word = unicode(attribute_1_word, "utf-8")

        time_sims = embeddings.get_time_sims(communion_word, attribute_1_word)
        time_sims = [time_sims[decade] for decade in range(1950, 2000, 10)]

        new_row = ["attribute_1", communion_word, attribute_1_word,
                   unicode("{communion_word}-{attribute_1_word}", "utf-8").format(communion_word=communion_word,
                                                                                  attribute_1_word=attribute_1_word)] + time_sims
        new_row = pd.Series(new_row, index=["attribute", "word_1", "word_2", "word_pair"] + range(1950, 2000, 10))
        new_row = new_row.T

        panel_data = panel_data.append(new_row, ignore_index=True)
        print unicode("{communion_word}-{attribute_1_word} 已完成", "utf-8").format(communion_word=communion_word,
                                                                                    attribute_1_word=attribute_1_word)

for communion_word in dictionary.loc[dictionary["communion"].notnull(), "communion"]:
    communion_word = unicode(communion_word, "utf-8")

    for attribute_2_word in dictionary.loc[dictionary["attribute_2"].notnull(), "attribute_2"]:
        attribute_2_word = unicode(attribute_2_word, "utf-8")

        time_sims = embeddings.get_time_sims(communion_word, attribute_2_word)
        time_sims = [time_sims[decade] for decade in range(1950, 2000, 10)]

        new_row = ["attribute_2", communion_word, attribute_2_word,
                   unicode("{communion_word}-{attribute_2_word}", "utf-8").format(communion_word=communion_word,
                                                                                  attribute_2_word=attribute_2_word)] + time_sims
        new_row = pd.Series(new_row, index=["attribute", "word_1", "word_2", "word_pair"] + range(1950, 2000, 10))
        new_row = new_row.T

        panel_data = panel_data.append(new_row, ignore_index=True)
        print unicode("{communion_word}-{attribute_2_word} 已完成", "utf-8").format(communion_word=communion_word,
                                                                                    attribute_2_word=attribute_2_word)

panel_data.to_csv("../my_analysis/panel_data.csv", index=False, encoding="utf-8")
