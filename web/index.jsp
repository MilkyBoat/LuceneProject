<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%--
  Created by IntelliJ IDEA.
  User: surface
  Date: 2019/10/19
  Time: 13:25
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh">
<head>
	<title>Lucene查询页</title>
	<meta charset="utf-8">
	<meta name="author" content="小辣稽">

	<style>
		#header{
			display: block;
			text-align: left;
			width: 100%;
			padding: 12px;
			background-color: #B03167;
			color: white;
		}
		.part{
			background-color: aliceblue;
			padding: 8px;
			margin: 12px 12px 12px 36px;
		}
		h1{
			font-size: 36px;
			text-align: left;
			width: 960px;
			margin: 12px;
		}
		h3{
			margin-left: 12px;
			color: cornflowerblue;
		}
		.select{
			margin-bottom: 8px;
			padding-bottom: 4px;
		}
		.submit{
			margin: 2px;
			padding: 12px;
			display: block;

			text-decoration: none;
			color: #666;
		}
		#rangeFuzzyLevel{
			height: 10px;
			padding-bottom: 0;
		}
		input{
			padding: 4px;
		}
		output{
			padding-left: 8px;
			padding-right: 8px;
		}
		form{
			margin-left: 24px;
		}
	</style>

</head>
<body>

<datalist id="field">
	<option value="全部位置">
	<option value="日期">
	<option value="正文">
	<option value="发件人">
	<option value="收件人">
	<option value="主题">
	<option value="文件名">
	<option value="文件位置">
</datalist>

<div id="header">
	<h6 style="font-size: 12px"><del>java</del>( html+css+javascript )<del>平时</del>( 大 )作业</h6>
	<h1>Lucene 数据检索页</h1>
</div>

<div class="part">
	<h3>精确匹配搜索</h3>
	<form action="search.jsp" method="GET">
		<input type="hidden" name="type" value="0">
		<div class = "search">
			<div class = "select">
				搜索内容: <input type="text" name="query"><br>
			</div>
			<div class="select">
				搜索区域: <input list="field" name="field"><br>
			</div>
			<div class="submit">
				<input type="submit" value="搜索" />
			</div>
		</div>
	</form>
</div>

<div class="part">
	<h3>通配符匹配搜索</h3>
	<form action="search.jsp" method="GET">
		<input type="hidden" name="type" value="1">
		<div class = "search">
			<div class = "select">
				搜索内容: <input type="text" name="query"><br>
			</div>
			<div class="select">
				搜索区域: <input list="field" name="field"><br>
			</div>
			<div class="submit">
				<input type="submit" value="搜索" />
			</div>
		</div>
	</form>
</div>

<div class="part">
	<h3>前缀匹配搜索</h3>
	<form action="search.jsp" method="GET">
		<input type="hidden" name="type" value="2">
		<div class = "search">
			<div class = "select">
				前缀内容: <input type="text" name="query"><br>
			</div>
			<div class="select">
				搜索区域: <input list="field" name="field"><br>
			</div>
			<div class="submit">
				<input type="submit" value="搜索" />
			</div>
		</div>
	</form>
</div>

<div class="part">
	<h3>模糊匹配搜索</h3>
	<form action="search.jsp" method="GET" oninput = "showLevel.value = parseInt(level.value)">
		<input type="hidden" name="type" value="3">
		<div class = "search">
			<div class = "select">
				搜索内容: <input type="text" name="query"><br>
			</div>
			<div class="select">
				搜索区域: <input list="field" name="field"><br>
			</div>
			<div class="select">
				模糊级别(0-3): <input id="rangeFuzzyLevel" type="range" min="0" max="2" value="0" name="level">
				<output name="showLevel">0</output><br>
				<p>模糊级别为 0 时等效于精确查找</p>
			</div>
			<div class="submit">
				<input type="submit" value="搜索" />
			</div>
		</div>
	</form>
</div>

</body>
</html>
