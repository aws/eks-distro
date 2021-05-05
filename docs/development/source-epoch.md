# Finding SOURCE_DATE_EPOCH value

For future reference because this was kinda an ordeal, these steps are how I found the value for SOURCE_DATE_EPOCH in a new Kubernetes version. Adjust accordingly if not using Firefox.

1. I went to the release tag page for 1.18.16
1. I clicked on the shortened commit hash ("7a98bb2"), which was just below the v1.18.16 git-tag to the left. This took me to the release commit for 1.18.16.
1. In the Firefox menu, I clicked on "web developer" -> "Inspector".
1. I hovered over the date in "[user who made commit] committed on Feb 17"
1. It said <relative-time datetime="2021-02-17T11:51:44Z" class="no-wrap" title="Feb 17, 2021, 3:51 AM PST">on Feb 17</relative-time>
1. I took the datetime value ("2021-02-17T11:51:44Z"), converted it to Epoch ("Epoch timestamp" on the linked website), and used this value as SOURCE_DATE_EPOCH

There probably is a better may to get this than these steps, but it this worked.
