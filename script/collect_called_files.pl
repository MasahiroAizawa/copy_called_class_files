#!/bin/perl

use strict;
use warnings;
use File::Path;


# スクリプトの第一引数は起点のファイル名
my $targetName = shift;
$targetName = "MainProg" if(!defined $targetName);

# スクリプトの第二引数は検索対象のトップのディレクトリ
my $defaultHome = shift;
$defaultHome = "src" if(!defined $defaultHome);

# スクリプトの第三匹数はコピー先のディレクトリ
my $copyHome = shift;
$copyHome = "copy" if(!defined $copyHome);

# newされているクラス一覧
my @calledClasses = ($targetName);

# コピー先の作成
my $targetDir ="$copyHome/$targetName"; 
if(! -d $targetDir){
	mkpath ["$targetDir"] or die $!;
}

# 全ファイルの検索、コピーの実行
foreach my$targetClass (@calledClasses){
	searchFile($targetClass, $defaultHome);
}

# 再帰ですべてのフォルダから対象のファイルを探して処理をする
# 引数
# file:対象のファイル名
# dir :対象のディレクトリ名
sub searchFile{
	my $target = shift;
	my $dir = shift;

	my @list = ();

	opendir(DIR, $dir);
	@list = readdir(DIR);
	closedir(DIR);

	foreach my $file(sort @list){
		next if($file =~ /^\.{1,2}$/); #. .. をスキップ

		if($file =~ /$target/){
			getClassFileNameByGrep("$dir/$file");
			copyTargetFile("$dir/$file");
		}
		elsif( -d "$dir/$file"){
			searchFile($target, "$dir/$file");
		}
		else{
		}
	}
}

# ファイルの中身を探して、newしたクラス名を拾う
# $targetFile : ファイルの中身を探すファイル
sub getClassFileNameByGrep{
	my $targetFile = shift;

	open(SEARCH_IN, "<$targetFile") or die;
	while(<SEARCH_IN>){
		if($_ =~ / new ([^\(]*)\(/){
			push(@calledClasses, $1);
		}
	}
	close(SEARCH_IN);
}

# 見つけたファイルをコピーする
# $targetFile : ファイルの中身を探すファイル
sub copyTargetFile{
	my $targetFile = shift;
	my $fileText = "";

	return if(! -e $targetFile);

	my $copyFile = $targetFile;
	$copyFile =~ s/^.*\/(.*)/$1/; 

	open(COPY_IN, "< $targetFile") or die;
	while(<COPY_IN>){
		$fileText .= $_;
	}
	close(COPY_IN);

	open(COPY_OUT, "> $targetDir/$copyFile") or die;
	print(COPY_OUT $fileText);
	close(COPY_OUT);
}

