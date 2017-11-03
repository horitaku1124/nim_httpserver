export function getUsefulContents(url, callback) {
  getJSON(url, data => callback(JSON.parse(data)));
}