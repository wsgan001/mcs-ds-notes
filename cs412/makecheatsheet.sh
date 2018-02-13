# gh-md-toc from https://raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc
grip Readme.md --export tmp_cheatsheet.html --no-inline
sed -i '' '/<link/d' ./tmp_cheatsheet.html
sed -i '' '/margin-top/d' ./tmp_cheatsheet.html
sed -i '' '/Readme.md/d' ./tmp_cheatsheet.html
head -4 tmp_cheatsheet.html > cheatsheet.html
echo "<link rel=\"stylesheet\" href=\"cheatsheet.css\" />" >> cheatsheet.html
tail -n +5 tmp_cheatsheet.html >> cheatsheet.html
rm tmp_cheatsheet.html

