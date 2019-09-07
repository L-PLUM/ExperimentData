import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class crawlerCode {
	public static void main(String[] args)  throws IOException {
		String path = "./address/etherscan/smartcontract.xls";
		String url1 = "https://etherscan.io/address/";
		List<Contract> list1 = readExcel(path);
		System.out.println(list1.size());

		List<Map<String, String>> list2 = new ArrayList<Map<String, String>>();

		for (int i =292; i <293; i++) {
			Map<String, String> map = new HashMap<String, String>();
			String url = url1 + list1.get(i).getAddress() + "#code";
			System.out.println(url);

			String code = getData(url);
			String collection = "code:" + "\n" + code;
			map.put("address:" + list1.get(i).getAddress() + "\n", collection);

			String filename = "";
			filename = i + ".sol";
			System.out.println(filename);
			File file = new File("./smartcontract/etherscan/ethercontract3/" + filename);
			BufferedWriter bw = null;
			try {
				bw = new BufferedWriter(new FileWriter(file));
				bw.write(code);
				bw.newLine();
				bw.flush();
				bw.close();
			} catch (Exception e) {
				e.printStackTrace();
			}

			System.out.println("done");
			System.out.println();
			list2.add(map);
		}
	}

	public static String getData(String url) throws IOException {
		String linkText = null;
		Document doc = Jsoup.connect(url)
				.header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0")
				.timeout(30000).get();
		Elements links = doc.select("pre.js-sourcecopyarea");
		for (Element link : links) {
			linkText = link.text();
		}
		return linkText;
	}


	public static List<Contract> readExcel(String path) throws IOException {
		List<Contract> list = new ArrayList<Contract>();

		InputStream ExcelFileToRead = new FileInputStream(path);
		HSSFWorkbook wb = new HSSFWorkbook(ExcelFileToRead);
		HSSFSheet sheet = wb.getSheetAt(0);
		System.out.println(sheet.getLastRowNum());
		HSSFRow row;

		for (int i = 0; i <= sheet.getLastRowNum(); i++) {
			row = sheet.getRow(i);
			Contract ct = new Contract();

			if (row == null) {
				continue;
			}

			int j = row.getFirstCellNum();

			ct.setAddress(row.getCell(j).toString());
			ct.setName(row.getCell(j + 1).toString());
			ct.setCompiler(row.getCell(j + 2).toString());
			ct.setVersion(row.getCell(j + 3).toString());
			ct.setBalance(row.getCell(j + 4).toString());
			ct.setTxCount(row.getCell(j + 5).toString());
			ct.setSettings(row.getCell(j + 6).toString());
			ct.setDateTime(row.getCell(j + 7).toString());

			list.add(ct);
		}
		return list;
	}
}
