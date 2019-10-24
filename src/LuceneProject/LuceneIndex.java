package LuceneProject;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Paths;

public class LuceneIndex {
	private static Logger logger = LogManager.getLogger(LuceneIndex.class);
	private IndexWriter writer;
	private int numIndexedTotal = 0;
	
	/***
	 * @Title: main
	 * @Description: 入口点，负责启动与关闭索引，并计时
	 * @param args: String[]
	 * @author  徐云凯
	 * @Datetime  2019/10/19
	 */
	public static void main(String[] args) {
		
		String indexDir = "D:\\NKU\\CS\\Java\\HomeWork\\LuceneProject\\index";
		String dataDir = "D:\\NKU\\CS\\Java\\HomeWork\\maildir";
		File data = new File(dataDir);

		LuceneIndex indexer = null;
		//索引开始时间
		long start = System.currentTimeMillis();
		try {
			indexer = new LuceneIndex(indexDir);
			indexer.index(data);
			try {
				indexer.close();
			} catch (IOException e) {
				logger.error("fall to close IndexWriter");
			}
		}
		catch (IOException e) {
			System.out.println("找不到指定的索引文件夹");
		}
		//索引结束时间
		long end = System.currentTimeMillis();
		logger.info("index " + (indexer != null ? indexer.numIndexedTotal : 0)
				+ " files, using" + (end - start)/1000 + " secs");
	}
	
	/***
	 * @Title: LuceneIndex
	 * @Description: LuceneIndex构造函数，初始化索引器，分析器等
	 * @param indexDir: 索引文件存放目录
	 * @Exception IOException: 找不到指定的索引文件夹存放位置
	 * @author  徐云凯
	 * @Datetime  2019/10/20
	 */
	public LuceneIndex(String indexDir) throws IOException {
		Directory directory = FSDirectory.open(Paths.get(indexDir));
		Analyzer analyzer = new StandardAnalyzer();
		IndexWriterConfig iwConfig = new IndexWriterConfig(analyzer);
		iwConfig.setOpenMode(IndexWriterConfig.OpenMode.CREATE);
		writer = new IndexWriter(directory, iwConfig);
	}
	
	/***
	 * @Title: index
	 * @Description: 递归遍历所有目录下的可读取文件进行索引
	 * @param data: 待索引目录
	 * @author  徐云凯
	 * @Datetime  2019/10/20
	 */
	public void index(File data){
		
		File[] subFolders = data.listFiles();
		
		for(File file : subFolders){
			if(file.isDirectory()){
				index(file);
			}
			else{
				int numIndexedRound = writer.numRamDocs();
				logger.debug("index file:" + file.toString());
				try {
					Document doc = analyze(file);
					try {
						writer.addDocument(doc);
					}
					catch (IOException e) {
						logger.error("IOException in addDocument() for file:" + file.toString());
					}
				}
				catch (IOException e) {
					logger.error("IOException in read file:" + file.toString());
				}
				finally{
					if(numIndexedRound > writer.numRamDocs()){
						logger.info("This round " + numIndexedRound + " files have been indexed");
						numIndexedTotal += numIndexedRound;
						numIndexedRound = writer.numRamDocs();
					}
				}
			}
		}
	}
	
	/***
	 * @Title: analyze
	 * @Description: 文件解析器，解析文件结构分割进入field进行索引
	 * @param f: 待索引文件
	 * @return org.apache.lucene.document.Document
	 * @author  徐云凯
	 * @Datetime  2019/10/20
	 */
	private Document analyze(File f) throws IOException {
		byte[] file = new byte[(int) f.length()];
		FileInputStream inputStream = new FileInputStream(f);
		inputStream.read(file);
		inputStream.close();
		String mail = new String(file);
		
		// 标题
		int subject_begin = mail.indexOf("Subject:") + 8;
		int subject_end = mail.indexOf("\r\n", subject_begin);
		String subject_string = mail.substring(subject_begin, subject_end);
		
		// 发件时间
		int data_begin = mail.indexOf("Date::") + 8;
		int data_end = mail.indexOf("\r\n", data_begin);
		String data_string = mail.substring(data_begin, data_end);
		
		// 发信人
		int from_begin = mail.indexOf("From:") + 5;
		int from_end = mail.indexOf("\r\n", from_begin);
		String from_string = mail.substring(from_begin, from_end);

		// 收件人
		int rec_begin = mail.indexOf("To:") + 5;
		int rec_end = mail.indexOf("\r\n", rec_begin);
		String rec_string = mail.substring(rec_begin, rec_end);
		
		// 正文
		int body_begin = mail.indexOf("\r\n\r\n") + 4;
		String body_string = mail.substring(body_begin);
		
		Document doc = new Document();
		doc.add(new TextField("contents", mail, Field.Store.YES));  //全文
		doc.add(new TextField("data", data_string, Field.Store.YES));   //时间日期
		doc.add(new TextField("body", body_string, Field.Store.YES));   //正文
		doc.add(new TextField("from", from_string, Field.Store.YES));   //发件人
		doc.add(new TextField("to", rec_string, Field.Store.YES));  //收件人
		doc.add(new TextField("subject", subject_string, Field.Store.YES)); //主题(标题)
		doc.add(new TextField("fileName", f.getName(), Field.Store.YES));   //文件名
		doc.add(new TextField("fullPath", f.getCanonicalPath(), Field.Store.YES));  //  文件路径
		
		return doc;
	}
	
	/***
	 * @Title: close
	 * @Description: 关闭writer
	 * @Exception IOException: writer关闭失败
	 * @author  徐云凯
	 * @Datetime  2019/10/21 16:42
	 */
	public void close() throws IOException {
		writer.close();
	}
}
