library(xml2)

html <- read_html("materiais/exemplos_de_aula/html_exemplo.html")

nodes <- xml_find_all(html, "//p")
node <- xml_find_first(html, "//p")

xml_text(nodes)
xml_attr(nodes, "style")

