## Code Change for Bulk Import

```bash
$ vim terraform-provider-aws/aws/resource_aws_iam_user.go
import (
  ...
  "github.com/aws/aws-sdk-go/aws/awserr"
  ...
)


func resourceAwsIamUserCreate(d *schema.ResourceData, meta interface{}) error {
	iamconn := meta.(*AWSClient).iamconn
	defaultTagsConfig := meta.(*AWSClient).DefaultTagsConfig
	tags := defaultTagsConfig.MergeTags(keyvaluetags.New(d.Get("tags").(map[string]interface{})))
	name := d.Get("name").(string)
	path := d.Get("path").(string)

	request := &iam.CreateUserInput{
		Path:     aws.String(path),
		UserName: aws.String(name),
	}

	if v, ok := d.GetOk("permissions_boundary"); ok {
		request.PermissionsBoundary = aws.String(v.(string))
	}

	if len(tags) > 0 {
		request.Tags = tags.IgnoreAws().IamTags()
	}

	log.Println("[DEBUG] Create IAM User request:", request)
	createResp, err := iamconn.CreateUser(request)
	if err != nil {
		if awsErr, ok := err.(awserr.Error); ok {
			if awsErr.Code() == iam.ErrCodeEntityAlreadyExistsException {
				d.SetId(name)
				return resourceAwsIamUserRead(d, meta)
			}
		}
		return fmt.Errorf("Error creating IAM User %s: %s", name, err)
	}

	d.SetId(aws.StringValue(createResp.User.UserName))

	return resourceAwsIamUserRead(d, meta)

# Then make a new binary and put it in terraform_plugins dir
```
