[k8smaster]
%{ for ip in k8smaster ~}
${ip}
%{ endfor ~}

[k8snode]
%{ for ip in k8snode ~}
${ip}
%{ endfor ~}