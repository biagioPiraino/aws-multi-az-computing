# AWS Multi-AZ Computing
<h3>Description</h3>
<p>Deploy secure, distributed and multi-AZ computing power on AWS using using <strong>Terraform</strong>.<p>
<hr>

<h3>Architecture</h3>
<img src="./aws-multi-az-computing.png?raw=true" width="300">
<hr>

<h3>How to use</h3>
<table>
  <thead>
    <tr>
      <th>Architecture</th>
      <th>Instructions</th>
    </tr>
  </thead>
  <tbody>
    <td>Multi AZ computing</td>
    <td>
      <ol>
        <li>
          Specify an <em>access and secret key</em> of an AWS account in the <em>provider</em> section inside the <em>init.tf</em> script.
         </li>
          <li>
             Run <em>terraform init</em> -> <em>terraform plan</em> -> <em>terraform apply</em> from your terminal.
          </li>
      </ol>
    </td>
  </tbody>
</table>
<hr>

<h3>References</h3>
<table>
  <thead>
    <tr>
      <th>References</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <a href="https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.23.0" rel="noopener noreferrer">Create a VPC using Terraform modules
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance" rel="noopener noreferrer">Create an EC2 instance using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb" rel="noopener noreferrer">Create an ALB using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group" rel="noopener noreferrer">Create a Security Group using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener" rel="noopener noreferrer">Create an ALB listener using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group" rel="noopener noreferrer">Create an ALB target group using Terraform
        </a>
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment" rel="noopener noreferrer">Create an ALB target group attachment using Terraform
        </a>
      </td>
    </tr>
  </tbody>
</table>
