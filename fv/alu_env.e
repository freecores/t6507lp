<'
import alu_components;
unit alu_env_u {
	agent: sbt_agent_u is instance;
};
extend sys {
	env: alu_env_u is instance;
};
'>
