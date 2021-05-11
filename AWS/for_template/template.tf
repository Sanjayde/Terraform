data "template_file" "init" {
    template = "${file("create_file.sh")}"
}