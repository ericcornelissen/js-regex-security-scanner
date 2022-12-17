const re = /(?<=\=(?:[^]*?:)?)(~)(?=\:|\=|\-|\+|\/|0|\s|$)/g;

const Component = ({ text }) => {
	return (
		<p>{re.test(text) ? "good" : "bad"}</p>
	)
}
