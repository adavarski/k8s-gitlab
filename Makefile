image:
	docker build -t davarski/k8s-gitlab .

release:
	docker login
	docker push davarski/k8s-gitlab
