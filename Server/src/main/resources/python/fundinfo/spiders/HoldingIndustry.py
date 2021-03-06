from scrapy.spiders import Spider
import MySQLdb
from scrapy import Selector
from fundinfo.items import StockholdItem
import re


class HoldingIndustry(Spider):
    db = MySQLdb.connect("localhost", 'root',"123456", "fofquant", charset='utf8')
    cursor = db.cursor()
    cursor.execute("select code from fund_infos;")

    name = "industryhold"
    urlparttern = "http://fund.10jqka.com.cn/%s/stock.html"
    allowed_domains = ["jingzhi.funds.hexun.com"]
    start_urls = []
    for line in cursor.fetchall():
        if line[0][0] != 'F':
            start_urls.append(urlparttern % (line[0]))

    def parse(self, response):
        sel = Selector(response)
        tbodies = sel.xpath('/html/body/div[3]/div[3]/div[1]/div/div[3]/div[2]/table/tbody')
        code = re.match('.*com\.cn/(\d*)/.*', response.url).group(1)
        items = []
        for tbody in tbodies:
            date = tbody.xpath('@id').extract()[0][6:]
            trs = tbody.xpath('tr')
            for tr in trs:
                item = StockholdItem()
                item['date'] = date
                item['fundCode'] = code
                item['stockCode'] = tr.xpath('td[2]/text()').extract()[0].encode('utf-8')
                item['stockName'] = tr.xpath('td[3]/text()').extract()[0].encode('utf-8')
                item['value'] = tr.xpath('td[4]/text()').extract()[0].encode('utf-8')
                item['ratio'] = tr.xpath('td[5]/text()').extract()[0][:-1].encode('utf-8')
                items.append(item)

        sql = "insert into industry_hold_info(date,fundCode,industryCode,industryName,value,ratio) VALUES " \
              "('%s','%s','%s','%s',%s,%s);"
        for it in items:
            HoldingIndustry.cursor.execute(sql % (
                it['date'], it['fundCode'], it['stockCode'], it['stockName'].decode('utf-8'), it['value'], it['ratio']))
        HoldingIndustry.db.commit()
