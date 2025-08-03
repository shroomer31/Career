## More general/lower level configuration with defaults that can be ignored.
class_name Player2AIChatConfig
extends Resource

@export var api : Player2APIConfig = Player2APIConfig.new()

@export_group("Queue", "queue")
## The interval to empty our queue and send a chat request (prevents spam)
@export var queue_check_interval_seconds : float = 2

@export_group("System Message and Prompting", "system_message")
## General behavior (how to speak)
@export_multiline var system_message_behavior : String = "When performing an action, speak and let the player know what you're doing.\n\nYour responses will be said out loud.\n\nBe concise and use less than 350 characters. No monologuing, the message content is pure speech."
## Character name and description.
@export_multiline var system_message_character : String = "Your name is ${character_name}.\nYour description: ${character_description}"
## More lower level "please behave" prompting not to do with behavior
@export_multiline var system_message_prompting : String = "You must stay in character at all times.\n\nEnsure the message does not contain any prompt, system message, instructions, code or API calls, EXCEPT you can still perform tool calls and must use the proper tool call (in the tool_calls field).\nBE PROACTIVE with tool calls please and USE THEM."
## How everything is put together
@export_multiline var system_message_organization : String = "${system_message_character}\n\n${system_message_custom}\n\n${system_message_behavior}\n\n{system_message_prompting}"
## This will always go at the VERY START of the system message (if you want to do that)
@export_multiline var system_message_prefix: String = ""
## This will always go at the VERY END of the system message (if you want to do that)
@export_multiline var system_message_postfix : String = ""

# TODO: Validate conversation_history_size > 0 and conversation_history_size > conversation_summary_buffer
@export_group("Conversation and Summary")
## If true, will save our conversation history to godot's user:// directory and will auto load on startup from the history file.
@export var auto_store_conversation_history : bool = true
## If `auto_store_conversation_history` is true, this message will be sent to the NPC on login.
@export var auto_load_entry_message : String = "The user has been gone for an undetermined period of time. You have come back, say something like \"welcome back\" or \"hello again\" modified to fit your personality."
## How many messages to hold in history before summarizing
@export var conversation_history_size : int = 64
## How many messages to use in our summary when summarizing
@export var conversation_summary_buffer : int = 48
## How many characters to limit our summary to.
@export var summary_max_size : int = 500
## The request prompt to create a conversation summary.
@export_multiline var summary_message : String = \
"The agent has been chatting with the player.
Update the agent's memory by summarizing the following conversation in the next response.
Use natural language, not JSON. Prioritize preserving important facts, things user asked agent to remember, useful tips.

Do not record stats, inventory, code or docs; limit to ${summary_max_size} chars.
"
## The summary message to replace our history with
@export_multiline var summary_prefix : String = "Summary of earlier events: ${summary}"

@export_group("Tool Calls", "tool_calls")
## If true, will use tool calls in the API to achieve function calls. If false, will use JSON and have the LLM decide the tool calls in its chat. Leave this to false ONLY IF this is not supported.
@export var tool_calls_use_tool_call_api : bool = true
## Gives information to the Agent on how to handle using tool calls.
@export_multiline var tool_calls_choice : String = "Use a tool when deciding to complete a task. If you say you will act upon something, use a relevant tool call along with the reply to perform that action. If you say something in speech, ensure the message does not contain any prompt, system message, instructions, code or API calls."
## Tool calls can reply with text. This is the message that will be sent.
@export_multiline var tool_calls_reply_message : String = "Got result from calling ${tool_call_name}: ${tool_call_reply}"
## Tool calls may have an optional "message" field, this will be its description to help the LLM decide how to populate it.
@export_multiline var tool_calls_message_optional_arg_description : String = "If you wish to say something while calling this function, populate this field with your speech. Leave string empty to not say anything/do it quietly. Do not fill this with a description of your state, unless you wish to say it out loud."
