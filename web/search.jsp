<%--
  Created by IntelliJ IDEA.
  User: surface
  Date: 2019/10/20
  Time: 19:51
  To change this template use File | Settings | File Templates.
--%>

<%@ page import="org.apache.lucene.store.Directory" %>
<%@ page import="org.apache.lucene.store.FSDirectory" %>
<%@ page import="org.apache.lucene.index.IndexReader" %>
<%@ page import="org.apache.lucene.index.DirectoryReader" %>
<%@ page import="org.apache.lucene.analysis.Analyzer" %>
<%@ page import="org.apache.lucene.analysis.standard.StandardAnalyzer" %>
<%@ page import="org.apache.lucene.queryparser.classic.QueryParser" %>
<%@ page import="org.apache.lucene.search.highlight.*" %>
<%@ page import="org.apache.lucene.document.Document" %>
<%@ page import="org.apache.lucene.analysis.TokenStream" %>
<%@ page import="org.apache.lucene.queryparser.classic.ParseException" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="org.apache.lucene.search.*" %>
<%@ page import="org.apache.lucene.index.Term" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="zh">

<head>
	<title>Lucene查找结果</title>
	<meta charset="utf-8">
	<meta name="author" content="小辣稽">
	<style>
		* {
			box-sizing: border-box;
		}
		h4{
			margin: 12px;
			padding: 8px;
			background-color: #eee;
		}
		.result{
			margin: 4px 12px 4px 12px;
			padding: 4px;
			display: block;
			text-decoration: none;
			color: #666;
		}
		.path{
			background-color: #dddeee;
			color: lightslategray;
			margin: 4px 12px 0 12px;
			padding: 12px;
		}
		.content{
			background-color: #eee;
			color: lightslategrey;
			margin: 0 12px 4px 12px;
			padding: 12px 12px 18px;
		}
	</style>
</head>

<body>

<%
	// 将传入的参数替换为内部参数
	Map<String, String> fi= new HashMap<String, String>(){{
		put("全部位置","contents");
		put("日期","data");
		put("正文","body");
		put("发件人","from");
		put("收件人","to");
		put("主题","subject");
		put("文件名","fileName");
		put("文件位置","fullPath");
	}};
	int type = 0;   // 查询类型
	if(request.getParameter("type")!=null)
		type = Integer.parseInt(request.getParameter("type"));
	int fuzzyLevel = 0;  // 模糊查询所需要的额外参数
	if(type == 2)
		fuzzyLevel = Integer.parseInt(request.getParameter("level"));
	String errorInfo = "url参数错误";  // 初始化参数异常时的提醒信息
	String q = request.getParameter("query");
	String ori = request.getParameter("field");
	String f0 = null;
	if(ori!=null)
		f0 = new String(ori.getBytes("ISO8859-1"), StandardCharsets.UTF_8); //  解码传入的中文参数
	String f = fi.get(f0);

	if(q != null && f!=null){
		String indexDir = "D:\\NKU\\CS\\Java\\HomeWork\\LuceneProject\\index\\";
		Directory dir = FSDirectory.open(Paths.get(indexDir));
		IndexReader reader = DirectoryReader.open(dir);
		IndexSearcher is = new IndexSearcher(reader);
		Analyzer analyzer = new StandardAnalyzer();

		Query query = null;
		switch (type){
			case 1:{
				query=new WildcardQuery(new Term(f,q));
				break;
			}
			case 2:{
				query = new PrefixQuery(new Term(f, q));
				break;
			}
			case 3:{
				query = new FuzzyQuery(new Term(f,q), fuzzyLevel);
				break;
			}
			default:{
				QueryParser parser = new QueryParser(f, analyzer);
				try {
					query = parser.parse(q);
				}
				catch (ParseException e) {
					errorInfo = "服务器端索引器创建异常";
				}
			}
		}

		long start = System.currentTimeMillis();    // 搜索开始

		TopDocs hits = null;
		try {
			hits = is.search(query, 30);
		}
		catch (IOException e) {
			errorInfo = "服务器端搜索异常";
		}

		QueryScorer scorer = new QueryScorer(query);
		Fragmenter fragmenter = new SimpleSpanFragmenter(scorer, 100);
		SimpleHTMLFormatter simpleHTMLFormatter = new SimpleHTMLFormatter("<font color='red'>","</font>");
		Highlighter highlighter = new Highlighter(simpleHTMLFormatter, scorer);
		highlighter.setTextFragmenter(fragmenter);

		long end = System.currentTimeMillis();	// 搜索结束

%>
<h4><%= ("在" + f0 + "中查找关键词“" + q + "”查找到总计 " + hits.totalHits.value + " 个结果，耗时" + (end - start) + "毫秒" ) %></h4>
<%
		for (ScoreDoc scoreDoc : hits.scoreDocs) {
			Document doc = null;
			try {
				doc = is.doc(scoreDoc.doc);
			}
			catch (IOException e) {
				errorInfo = "服务器端搜索结果解析异常";
			}
			String content = doc.get(f);
			String highlighter_string = "";
			if(content!=null){
				try {
					TokenStream tokenStream = analyzer.tokenStream(f, content);
					try {
						highlighter_string = highlighter.getBestFragment(tokenStream, content);
					}
					catch (InvalidTokenOffsetsException e) {
						errorInfo = "服务器端搜索结果编码解析异常";
					}
				} catch (IOException e) {
					errorInfo = "服务器端TokenStream初始化异常";
				}
%>
<div class="result">
	<p class="path">文件位置：<ins>.\<%=doc.get("fullPath").substring(doc.get("fullPath").indexOf("maildir\\") + 8)%></ins> </p>
	<p class="content">检索到的文本： <%=highlighter_string%></p>
</div>
<%
			}
		}
		try {
			reader.close();
		}
		catch (IOException e) {
			errorInfo = "服务器端读取器关闭失败";
		}
	}
	else{
%>
<p> <%=errorInfo%> </p>
<%
	}
%>

</body>
</html>
