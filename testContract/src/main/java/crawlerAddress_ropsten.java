import net.sf.json.JSONArray;
import org.apache.poi.hssf.usermodel.*;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;

import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;

public class crawlerAddress_ropsten {

    @SuppressWarnings("deprecation")
    public static void main(String[] args) throws Exception {
        // 采集的网址
        String url = "https://ropsten.etherscan.io/contractsVerified/";
       // int  total_page =20;
        Document document = Jsoup.connect(url).userAgent("Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36").get();
        // 获取审查页面的页数信息
        Elements pages = document.select("nav").select("ul.pagination.pagination-sm.mb-0").select("li.page-item.disabled").select("span").select("strong:nth-child(2)");
       // System.out.println(pages);
        int  total_page = Integer.parseInt(pages.text());
        System.out.println(total_page);

        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("sheet1");
        HSSFRow row = sheet.createRow(0);
        HSSFCellStyle style = wb.createCellStyle();
        style.setAlignment(HSSFCellStyle.ALIGN_CENTER);

        HSSFCell cell1 = row.createCell(0);
        cell1.setCellValue("Address");
        cell1.setCellStyle(style);
        HSSFCell cell2 = row.createCell(1);
        cell2.setCellValue("Name");
        cell2.setCellStyle(style);
        HSSFCell cell3 = row.createCell(2);
        cell3.setCellValue("Compiler");
        cell3.setCellStyle(style);
        HSSFCell cell4 = row.createCell(3);
        cell4.setCellValue("Version");
        cell4.setCellStyle(style);
        HSSFCell cell5 = row.createCell(4);
        cell5.setCellValue("Balance");
        cell5.setCellStyle(style);
        HSSFCell cell6 = row.createCell(5);
        cell6.setCellValue("TxCount");
        cell6.setCellStyle(style);
        HSSFCell cell7 = row.createCell(6);
        cell7.setCellValue("Settings");
        cell7.setCellStyle(style);
        HSSFCell cell8 = row.createCell(7);
        cell8.setCellValue("DateTime");
        cell8.setCellStyle(style);

        for (int current_page = 1; current_page <= total_page; current_page++) {
            if (current_page == 1) {
                List<Contract> list = getData(url + current_page);
                JSONArray array = new JSONArray();
                array.add(list);
                for (int i = 0; i < list.size(); i++) {
                    row = sheet.createRow(i + 1);

                    row.createCell(0).setCellValue(list.get(i).getAddress());
                    row.createCell(1).setCellValue(list.get(i).getName());
                    row.createCell(2).setCellValue(list.get(i).getCompiler());
                    row.createCell(3).setCellValue(list.get(i).getVersion());
                    row.createCell(4).setCellValue(list.get(i).getBalance());
                    row.createCell(5).setCellValue(list.get(i).getTxCount());
                    row.createCell(6).setCellValue(list.get(i).getSettings());
                    row.createCell(7).setCellValue(list.get(i).getDateTime());

                }
                System.out.println("**************************************");

            } else {
                List<Contract> list = getData(url + current_page);
                JSONArray array = new JSONArray();
                array.add(list);
                for (int i = 0; i < list.size(); i++) {
                    row = sheet.createRow((short) (sheet.getLastRowNum() + 1)); //现有的行号后面追加
                    //row = sheet.createRow(i + 1);
                    row.createCell(0).setCellValue(list.get(i).getAddress());
                    row.createCell(1).setCellValue(list.get(i).getName());
                    row.createCell(2).setCellValue(list.get(i).getCompiler());
                    row.createCell(3).setCellValue(list.get(i).getVersion());
                    row.createCell(4).setCellValue(list.get(i).getBalance());
                    row.createCell(5).setCellValue(list.get(i).getTxCount());
                    row.createCell(6).setCellValue(list.get(i).getSettings());
                    row.createCell(7).setCellValue(list.get(i).getDateTime());
                }
            }

            try {
                FileOutputStream fos = new FileOutputStream("./address/ropsten/ropstencontract2.xls");
                wb.write(fos);
                fos.flush();
                fos.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        System.out.println("done");

    }

    public static List<Contract> getData(String url) throws Exception {
        List<Contract> contractList = new ArrayList<Contract>();
        Document doc = Jsoup.connect(url)
                .header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0").timeout(30000).get();

        Elements elements2 = doc.select("div.table-responsive").select("table").select("tbody").select("tr");

        for (int i = 0; i < elements2.size(); i++) {
            String contract = elements2.get(i).select("td").get(0).text();
            System.out.println(contract);
            String name = elements2.get(i).select("td").get(1).text();
            String compiler = elements2.get(i).select("td").get(2).text();
            String version = elements2.get(i).select("td").get(3).text();
            String balance = elements2.get(i).select("td").get(4).text();
            String txCount = elements2.get(i).select("td").get(5).text();
            String settings = elements2.get(i).select("td").get(6).text();
            String dateTime = elements2.get(i).select("td").get(7).text();
            contractList.add(new Contract(contract, name, compiler, version, balance, txCount, settings, dateTime));
        }
        return contractList;
    }
}