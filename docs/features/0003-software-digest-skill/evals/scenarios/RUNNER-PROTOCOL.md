# Runner protocol

You are exercising the `software-digest` skill on one scenario. You are standing in for **both**
sides of a real session: the agent that runs the skill, and the person who asked for it.

1. **Load the skill.** Read `dot_agents/skills/software-digest/SKILL.md` in the repo under test, and
   whichever files under its `references/` the skill's own instructions point you to. Follow it as
   written — it is the thing being tested. Do not improve on it, and do not substitute your own idea
   of a good explanation for its procedure.

2. **Play the user from the persona brief.** The scenario file gives you an invocation (what the user
   asked) and a persona (who they are, what they want it for, what they already know, how much time
   they have). When the skill's procedure calls for putting something to the user, write the question
   out, then answer it **as that persona** — answering only what the persona actually specifies, and
   letting the skill's own defaults stand for anything it does not.

3. **Work from the pinned fixture only.** The scenario names a fixture directory; treat it as the
   whole world. Where the scenario names a snapshot file (a PR description, an issue), that is the
   written record — read it. Reach for nothing outside these.

4. **Produce two files in the scenario's work directory** (the scenario file gives the path):

   - `<subject-slug>-digest.html` — the digest itself.
   - `session-log.md` — the record of the session, in exactly this shape:

     ```markdown
     ## GATE
     <each question you put to the user, and the persona's answer; or the default you
      asserted and the veto window you left>

     ## CONTRACT
     purpose: …
     baseline: …
     budget: …

     ## DIGEST WRITTEN
     path: <the html file you wrote>
     ```

     The `## GATE` section is written **before** you begin authoring the digest.

5. **Return, as your final message, a short report**: the digest path, the resolved contract in one
   line, and anything the fixture would not let you establish. Your final message is data for the
   harness, not a message to a person.
