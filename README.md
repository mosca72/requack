# requack
Requack supports my software quality-control activities as a checklist maintenance tool.

I use Requack to make sure that the best practices are implemented in my software by following these steps:

I define my software objects, their classes and a checklist for each class - all in a single file (req_config.txt)

I run the program which prints all the facts I want to verify on all my objects (gawk -f req.awk)

Whenever I verify a fact for an object, I add a VERIFIED item to the file (req_config.txt)

Keywords:

implementing best practices, declarative programming, software quality control, checklists, development tools

